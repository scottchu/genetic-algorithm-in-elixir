defmodule Framework.Chromosome do
  @type t() :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: number(),
          age: integer()
        }

  @enforce_keys :genes

  defstruct [
    :genes,
    size: 0,
    fitness: 0,
    age: 0
  ]

  @spec create(genes :: Enum.t()) :: t()
  def create(genes) do
    %__MODULE__{
      genes: genes,
      size: length(genes)
    }
  end

  @spec update(chromosome :: t(), fitness :: number()) :: t()
  def update(%__MODULE__{age: age} = chromosome, fitness) do
    %__MODULE__{chromosome | fitness: fitness, age: age + 1}
  end
end
