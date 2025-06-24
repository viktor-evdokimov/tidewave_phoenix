defmodule Tidewave.MCP.Tools.FSSyncTest do
  # we use File.cd to change the working directory, so these tests run synchronously
  use ExUnit.Case, async: false

  alias Tidewave.MCP.Tools.FS

  setup context do
    if tmp_dir = context[:tmp_dir] do
      # Change to the test directory to make grep search there
      original_dir = File.cwd!()
      File.cd!(tmp_dir)

      # also overwrite the stored MCP working directory
      old_root = Application.get_env(:tidewave, :root)
      Application.put_env(:tidewave, :root, tmp_dir)

      on_exit(fn ->
        # Restore original directory
        File.cd!(original_dir)
        Application.put_env(:tidewave, :root, old_root)
      end)

      %{test_dir: tmp_dir}
    else
      :ok
    end
  end

  describe "list_project_files/1 with glob pattern" do
    @describetag :tmp_dir

    setup %{tmp_dir: tmp_dir} do
      files = [
        "file1.txt",
        "file2.md",
        "file3.ex",
        Path.join("subdir", "file4.ex")
      ]

      Enum.each(files, fn file ->
        full_path = Path.join(tmp_dir, file)
        File.mkdir_p!(Path.dirname(full_path))
        File.write!(full_path, "Test content for #{file}")
      end)
    end

    test "finds files matching pattern" do
      assert {:ok, text} = FS.list_project_files(%{"glob_pattern" => "*.txt"})

      assert text =~ "file1.txt"
      refute text =~ "file2.md"
    end

    test "finds files with wildcard pattern" do
      assert {:ok, text} = FS.list_project_files(%{"glob_pattern" => "*.ex"})

      assert text =~ "file3.ex"
      assert text =~ "file4.ex"
      refute text =~ "file1.txt"
    end

    test "respects .gitignore by default even with glob_pattern" do
      File.write!(".gitignore", "*.txt")

      assert {:ok, text} =
               FS.list_project_files(%{"glob_pattern" => "*.txt"})

      refute text =~ "file1.txt"
    end

    test "ignores .gitignore when include_ignored is true" do
      File.write!(".gitignore", "*.txt")

      assert {:ok, text} =
               FS.list_project_files(%{
                 "glob_pattern" => "*.txt",
                 "include_ignored" => true
               })

      assert text =~ "file1.txt"
    end
  end
end
