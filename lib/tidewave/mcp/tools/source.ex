defmodule Tidewave.MCP.Tools.Source do
  @moduledoc false

  def tools do
    [
      %{
        name: "get_source_location",
        description: """
        Returns the source location for the given module (or function).

        This works for modules in the current project, as well as dependencies,
        but not for modules included in Elixir itself.

        This tool only works if you know the specific module (and optionally function) that is being targeted.
        If that is the case, prefer this tool over grepping the file system.
        """,
        inputSchema: %{
          type: "object",
          required: ["module"],
          properties: %{
            module: %{
              type: "string",
              description:
                "The module to get source location for. When this is the single argument passed, the entire module source is returned."
            },
            function: %{
              type: "string",
              description:
                "The function to get source location for. When used, a module must also be passed."
            }
          }
        },
        callback: &get_source_location/1
      }
    ]
  end

  def get_source_location(args) do
    case args do
      %{"module" => module} ->
        mod = string_to_module(module)
        function = if function = args["function"], do: String.to_atom(function)
        arity = :*
        result = open_mfa(mod, function, arity)

        case result do
          {_source_file, _module_pair, {fun_file, fun_line}} ->
            {:ok, "#{fun_file}:#{fun_line}"}

          {_source_file, {module_file, module_line}, nil} ->
            {:ok, "#{module_file}:#{module_line}"}

          {source_file, nil, nil} ->
            {:ok, source_file}

          {:error, error} ->
            {:error, "Failed to get source location: #{inspect(error)}"}
        end

      _ ->
        {:error, :invalid_arguments}
    end
  end

  defp string_to_module(module) do
    case module do
      <<":", erl_module::binary>> -> String.to_existing_atom(erl_module)
      module -> Module.concat([module])
    end
  end

  # open helpers, extracted from IEx.Introspection
  defp open_mfa(module, fun, arity) do
    case Code.ensure_loaded(module) do
      {:module, _} ->
        case module.module_info(:compile)[:source] do
          [_ | _] = source ->
            with {:ok, source} <- rewrite_source(module, source) do
              open_abstract_code(module, fun, arity, source)
            end

          _ ->
            {:error, "source code is not available"}
        end

      _ ->
        {:error, "module is not available"}
    end
  end

  defp open_abstract_code(module, fun, arity, source) do
    fun = Atom.to_string(fun)

    with [_ | _] = beam <- :code.which(module),
         {:ok, {_, [abstract_code: abstract_code]}} <- :beam_lib.chunks(beam, [:abstract_code]),
         {:raw_abstract_v1, code} <- abstract_code do
      {_, module_pair, fa_pair} =
        Enum.reduce(code, {source, nil, nil}, &open_abstract_code_reduce(&1, &2, fun, arity))

      {source, module_pair, fa_pair}
    else
      _ ->
        {source, nil, nil}
    end
  end

  defp open_abstract_code_reduce(entry, {file, module_pair, fa_pair}, fun, arity) do
    case entry do
      {:attribute, ann, :module, _} ->
        {file, {file, :erl_anno.line(ann)}, fa_pair}

      {:function, ann, ann_fun, ann_arity, _} ->
        case Atom.to_string(ann_fun) do
          "MACRO-" <> ^fun when arity == :* or ann_arity == arity + 1 ->
            {file, module_pair, fa_pair || {file, :erl_anno.line(ann)}}

          ^fun when arity == :* or ann_arity == arity ->
            {file, module_pair, fa_pair || {file, :erl_anno.line(ann)}}

          _ ->
            {file, module_pair, fa_pair}
        end

      _ ->
        {file, module_pair, fa_pair}
    end
  end

  @elixir_apps ~w(eex elixir ex_unit iex logger mix)a
  @otp_apps ~w(kernel stdlib)a
  @apps @elixir_apps ++ @otp_apps

  defp rewrite_source(module, source) do
    case :application.get_application(module) do
      {:ok, app} when app in @apps ->
        {:error,
         "Cannot get source of core libraries, use the eval_project tool with the `h(...)` helper to read documentation instead."}

      _ ->
        beam_path = :code.which(module)

        if is_list(beam_path) and List.starts_with?(beam_path, :code.root_dir()) do
          app_vsn = beam_path |> Path.dirname() |> Path.dirname() |> Path.basename()
          {:ok, Path.join([:code.root_dir(), "lib", app_vsn, rewrite_source(source)])}
        else
          {:ok, List.to_string(source)}
        end
    end
  end

  defp rewrite_source(source) do
    {in_app, [lib_or_src | _]} =
      source
      |> Path.split()
      |> Enum.reverse()
      |> Enum.split_while(&(&1 not in ["lib", "src"]))

    Path.join([lib_or_src | Enum.reverse(in_app)])
  end
end
