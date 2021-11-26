defmodule Framework do
  alias Framework.Chromosome
  alias Framework.Problem

  @spec run(problem :: Problem.t(), opts :: keyword()) :: any()
  def run(problem, opts \\ []) do
    initialize(&problem.genotype/0, opts)
    |> evolve(problem, opts)
  end

  @default_population_size 100
  @spec initialize(genotype :: fun(), opts :: keyword()) :: Enum.t()
  def initialize(genotype, opts \\ []) do
    opts
    |> Keyword.get(:population_size, @default_population_size)
    |> (&Range.new(1, &1)).()
    |> Enum.map(fn _ -> genotype.() end)
  end

  @spec evaluate(population :: Enum.t(), fitness :: fun(), opts :: keyword()) :: Enum.t()
  def evaluate(population, fitness, _opts \\ []) do
    population
    |> Enum.map(&Chromosome.update(&1, fitness.(&1)))
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  @spec select(population :: Enum.t(), opts :: keyword()) :: Enum.t()
  def select(population, _opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  @spec select(population :: Enum.t(), opts :: keyword()) :: Enum.t()
  def crossover(population, _opts \\ []) do
    population
    |> Enum.reduce([], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1.genes))
      {h1, t1} = Enum.split(p1.genes, cx_point)
      {h2, t2} = Enum.split(p2.genes, cx_point)
      c1 = %Chromosome{p1 | genes: h1 ++ t2}
      c2 = %Chromosome{p2 | genes: h2 ++ t1}

      [c1, c2 | acc]
    end)
  end

  @mutation_threshold 0.05
  @spec mutation(population :: Enum.t(), opts :: keyword()) :: Enum.t()
  def mutation(population, opts \\ []) do
    threshold = Keyword.get(opts, :mutation_threshold, @mutation_threshold)

    population
    |> Enum.map(&mutate(&1, :rand.uniform(), threshold))
  end

  defp mutate(chromosome, n, t) when n < t do
    %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
  end

  defp mutate(chromosome, _n, _t), do: chromosome

  @spec evolve(population :: Enum.t(), problem :: Problem.t(), opts :: keyword()) :: Enum.t()
  def evolve(population, problem, opts \\ []) do
    population =
      population
      |> evaluate(&problem.fitness_function/1, opts)

    best = hd(population)

    IO.write("\rCurrent Best: #{best.fitness}")

    case problem.terminate?(population) do
      false ->
        population
        |> select(opts)
        |> crossover(opts)
        |> mutation(opts)
        |> evolve(problem, opts)

      true ->
        best
    end
  end
end
