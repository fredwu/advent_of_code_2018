defmodule AdventOfCode2018.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [t: :test],
    ]
  end

  defp deps do
    []
  end

  defp aliases do
    [
      t: "test --exclude output"
    ]
  end
end
