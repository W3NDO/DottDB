defmodule Mix.Tasks.FormatTest do
  @moduledoc """
  Because we can't chain commands in mix as we do with rails, this task is here just so I can run format and compile in one command
  """

  @shortdoc "Formats and tests your code"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("format")
    Mix.env() == :test or raise "You need to run this task in the test environment"
    Mix.Task.run("test")
  end
end
