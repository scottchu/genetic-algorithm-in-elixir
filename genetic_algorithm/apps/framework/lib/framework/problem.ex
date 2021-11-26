defmodule Framework.Problem do
  alias Framework.Chromosome

  @type t() :: module()
  @callback genotype :: Chromosome.t()

  @callback fitness_function(chromosome :: Chromosome.t()) :: any()

  @callback terminate?(population :: Enum.t()) :: boolean()
end
