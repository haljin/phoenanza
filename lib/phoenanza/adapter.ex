defmodule Phoenanza.EtsAdapter do
    @behaviour Ecto.Adapter
    use GenServer
    require Logger

    defmacro __before_compile__ _ do
    end

    def child_spec(_, _) do
        import Supervisor.Spec
        worker(__MODULE__, [])
    end

    
    def autogenerate(field_type) do
        Logger.info("autogenerate #{inspect(field_type)}")
        :not_implemented
    end

    # Returns the childspec that starts the adapter process
    def delete(repo, schema_meta, filters, options) do
        Logger.info("delete #{inspect(repo)}, #{inspect(schema_meta)}, #{inspect(filters)}, #{inspect(options)}")
        :not_implemented
    end

    # Deletes a single struct with the given filters
    def dumpers(_primitive_type, ecto_type) do
        # Logger.info("dumpers #{inspect(primitive_type)}, #{inspect(ecto_type)}")
        [ecto_type]
    end

    # Returns the dumpers for a given type
    def ensure_all_started(repo, type) do
        Logger.info("ensure_all_started #{inspect(repo)}, #{inspect(type)}")
        :not_implemented
    end

    # Ensure all applications necessary to run the adapter are started
    def execute(repo, query_meta, query, params, arg4, options) do
        Logger.info("execute #{inspect(repo)}, #{inspect(query_meta)}, #{inspect(query)}, #{inspect(params)}, #{inspect(arg4)}, #{inspect(options)}}")
        :not_implemented
    end

    # Executes a previously prepared query
    def insert(repo, schema_meta, fields, on_conflict, returning, options) do
        Logger.info("insert #{inspect(repo)}, #{inspect(schema_meta)}, #{inspect(fields)}, #{inspect(on_conflict)}, #{inspect(returning)}, #{inspect(options)}}")
        :not_implemented
    end

    # Inserts a single new struct in the data store
    def insert_all(repo, schema_meta, header, list, on_conflict, returning, options) do
        Logger.info("insert_all #{inspect(repo)}, #{inspect(schema_meta)}, #{inspect(header)}, #{inspect(list)}, #{inspect(on_conflict)},  #{inspect(returning)}, #{inspect(options)}}")
        :not_implemented
    end

    # Inserts multiple entries into the data store
    def loaders(primitive_type,_ecto_type) do
        Logger.info("insert_all #{inspect(primitive_type)}, #{inspect(_ecto_type)}")
    end

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end


    
end