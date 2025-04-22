defmodule Tidewave.MCP.Diff do
  @moduledoc false

  @default_context 3

  @doc """
  Generates a diff string between two strings.

  ## Parameters

    * `old` - The original string
    * `new` - The new string to compare against
    * `opts` - Options for the diff:
      * `:context` - Number of context lines to show around changes (default: #{@default_context})
      * `:collapse` - Whether to collapse unchanged lines (default: true)

  ## Returns

  A string in diff format, with:
    * Lines prefixed with '-' for lines removed from `old`
    * Lines prefixed with '+' for lines added in `new`
    * Lines without prefix for unchanged lines
    * Collapsed sections shown as "... [X lines skipped] ..."

  ## Examples

      iex> Tidewave.MCP.Diff.diff("hello\nworld", "hello\nthere\nworld")
      "  hello\n+ there\n  world"

      iex> Tidewave.MCP.Diff.diff("line1\nline2\nline3\nline4\nline5\nline6", "line1\nline2\nmodified\nline4\nline5\nline6")
      "  line1\n  line2\n- line3\n+ modified\n  line4\n  line5\n  line6"

      iex> Tidewave.MCP.Diff.diff("line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8\nline9\nline10", "line1\nline2\nline3\nline4\nmodified\nline6\nline7\nline8\nline9\nline10", context: 2)
      "  line2\n  line3\n  line4\n- line5\n+ modified\n  line6\n  line7\n  line8"

  """
  @spec diff(String.t(), String.t(), keyword()) :: String.t()
  def diff(old, new, opts \\ []) do
    context = Keyword.get(opts, :context, @default_context)
    collapse = Keyword.get(opts, :collapse, true)

    old_lines = String.split(old, "\n")
    new_lines = String.split(new, "\n")

    # First generate a raw diff with all lines
    raw_diff = do_diff(old_lines, new_lines)

    # Then process the raw diff to collapse unchanged lines if needed
    processed_diff =
      if collapse do
        collapse_unchanged(raw_diff, context)
      else
        raw_diff
      end

    Enum.join(processed_diff, "\n")
  end

  defp do_diff(old_lines, new_lines) do
    myers_diff(old_lines, new_lines, 0, 0, [])
    |> Enum.reverse()
  end

  defp myers_diff([], [], _, _, acc), do: acc

  defp myers_diff([], [new_line | new_rest], _, _, acc) do
    # All old lines consumed, new lines remain (additions)
    myers_diff([], new_rest, 0, 0, ["+ " <> new_line | acc])
  end

  defp myers_diff([old_line | old_rest], [], _, _, acc) do
    # All new lines consumed, old lines remain (deletions)
    myers_diff(old_rest, [], 0, 0, ["- " <> old_line | acc])
  end

  defp myers_diff([old_line | old_rest], [new_line | new_rest], _, _, acc)
       when old_line == new_line do
    # Lines match, keep as is
    myers_diff(old_rest, new_rest, 0, 0, ["  " <> old_line | acc])
  end

  defp myers_diff([old_line | old_rest], [new_line | new_rest], _, _, acc) do
    # Lines don't match, mark as removed and added
    acc = ["+ " <> new_line | acc]
    acc = ["- " <> old_line | acc]
    myers_diff(old_rest, new_rest, 0, 0, acc)
  end

  @spec collapse_unchanged([String.t()], non_neg_integer()) :: [String.t()]
  defp collapse_unchanged(diff_lines, context) do
    # Group the diff lines into changed and unchanged sections
    {sections, current_section, current_type} =
      Enum.reduce(diff_lines, {[], [], :unchanged}, fn
        line, {sections, current_section, current_type} ->
          line_type = if String.starts_with?(line, "  "), do: :unchanged, else: :changed

          if line_type == current_type do
            # Continue the current section
            {sections, [line | current_section], current_type}
          else
            # Start a new section
            new_sections =
              if current_section == [],
                do: sections,
                else: [{current_type, Enum.reverse(current_section)} | sections]

            {new_sections, [line], line_type}
          end
      end)

    # Add the final section
    sections =
      if current_section == [],
        do: sections,
        else: [{current_type, Enum.reverse(current_section)} | sections]

    sections = Enum.reverse(sections)

    # Process the sections to add context
    process_sections(sections, context)
  end

  defp process_sections(sections, context) do
    {result, _} =
      Enum.reduce(sections, {[], :none}, fn {type, lines}, {acc, prev_collapsed} ->
        case type do
          :changed ->
            # Keep all changed lines
            {acc ++ lines, :none}

          :unchanged ->
            if length(lines) <= 2 * context do
              # If the section is small enough, keep all lines
              {acc ++ lines, :none}
            else
              # Otherwise, keep only context lines at the beginning and end
              {leading, middle, trailing} = split_context(lines, context)

              # Only add the "skipped" indicator if we haven't just added one
              skipped_indicator =
                if prev_collapsed != :none do
                  []
                else
                  ["... [#{length(middle)} lines skipped] ..."]
                end

              {acc ++ leading ++ skipped_indicator ++ trailing, :collapsed}
            end
        end
      end)

    result
  end

  defp split_context(lines, context) do
    # Get leading context
    {leading, rest} = Enum.split(lines, context)

    # Get trailing context (if there's enough lines left)
    rest_length = length(rest)

    {middle, trailing} =
      if rest_length > context do
        Enum.split(rest, rest_length - context)
      else
        {[], rest}
      end

    {leading, middle, trailing}
  end
end
