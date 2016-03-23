defmodule AWSAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :aws_auth,
     version: "0.2.5",
     elixir: "~> 1.0",
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger, :timex, :tzdata]]
  end

  defp deps do
    [{:timex, "~> 2.0"}]
  end

  defp description do
    """
    AWS Signature Version 4 Signing Library
    """
  end

  defp package do
    [
     files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     contributors: ["Bryan Joseph"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/bryanjos/aws_auth"}
    ]
  end
end
