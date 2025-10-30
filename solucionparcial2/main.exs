defmodule Main do
  alias Inventario
  alias Pieza
  alias Movimiento

  def run do
    IO.puts("=== SISTEMA DE INVENTARIO ===")

    # 1) Procesar piezas
    IO.puts("\n1) Leyendo piezas.csv...")
    case Inventario.leer_piezas("piezas.csv") do
      {:ok, piezas} ->
        IO.puts("Piezas cargadas: #{length(piezas)}")
        Enum.each(piezas, fn p -> IO.inspect(p) end)

        # 1B: Contar stock bajo
        umbral = 40
        count_bajo = Pieza.contar_stock_bajo(piezas, umbral)
        IO.puts("Piezas con stock < #{umbral}: #{count_bajo}")

        # 2) Procesar movimientos
        IO.puts("\n2) Leyendo movimientos.csv...")
        case Inventario.leer_movimientos("movimientos.csv") do
          {:ok, movimientos} ->
            IO.puts("Movimientos cargados: #{length(movimientos)}")
            Enum.each(movimientos, fn m -> IO.inspect(m) end)

            # 2A: Aplicar movimientos
            piezas_actualizadas = Inventario.aplicar_movimientos(piezas, movimientos)
            IO.puts("\nPiezas actualizadas después de movimientos:")
            Enum.each(piezas_actualizadas, fn p -> IO.inspect(p) end)

            # 2B: Guardar inventario actual
            IO.puts("\nGuardando inventario_actual.csv...")
            case Inventario.guardar_inventario(piezas_actualizadas, "inventario_actual.csv") do
              {:ok, mensaje} -> IO.puts(mensaje)
              {:error, razon} -> IO.puts("Error: #{razon}")
            end

            # 3) Cantidad total en rango de fechas
            IO.puts("\n3) Calculando movimientos en rango de fechas...")
            fecha_ini = "2025-09-10"
            fecha_fin = "2025-09-12"
            total_movido = Movimiento.cantidad_total_en_rango(movimientos, fecha_ini, fecha_fin)
            IO.puts("Total movido entre #{fecha_ini} y #{fecha_fin}: #{total_movido}")

            # 4) Eliminar duplicados
            IO.puts("\n4) Eliminando duplicados...")
            piezas_con_duplicados = piezas ++ [List.first(piezas)]  # Agregar duplicado para prueba
            piezas_sin_duplicados = Pieza.eliminar_duplicados(piezas_con_duplicados)
            IO.puts("Original: #{length(piezas_con_duplicados)}, Sin duplicados: #{length(piezas_sin_duplicados)}")

          {:error, razon} ->
            IO.puts("Error cargando movimientos: #{razon}")
        end

      {:error, razon} ->
        IO.puts("Error cargando piezas: #{razon}")
    end

    # 5) Prueba de la función ComplejoB
    IO.puts("\n5) Prueba de función ComplejoB:")
    test_complejo_b()
  end

  defp test_complejo_b do
    # Pruebas simples de la función f
    IO.puts("f(0) = #{ComplejoB.f(0)}")
    IO.puts("f(1) = #{ComplejoB.f(1)}")
    IO.puts("f(2) = #{ComplejoB.f(2)}")
    IO.puts("f(3) = #{ComplejoB.f(3)}")
  end
end

# Módulo para el punto 5
defmodule ComplejoB do
  def f(n) when n <= 1, do: n + 2

  def f(n) when rem(n, 2) == 0 do
    f(n - 1) - rem(n, 3) + f(div(n, 2))
  end

  def f(n) do
    g(n - 2, rem(n, 4))
  end

  defp g(a, 0), do: f(a - 1)
  defp g(a, r), do: f(a) * (r + 1)
end

# Archivos CSV de ejemplo
defmodule CSVGenerator do
  def generate_example_files do
    # Crear piezas.csv
    piezas_content = """
    COD123,Resistor,47,ohm,120
    COD124,Capacitor,100,uF,35
    COD125,Inductor,10,mH,60
    COD126,LED,5,V,25
    """

    # Crear movimientos.csv
    movimientos_content = """
    COD123,ENTRADA,50,2025-09-10
    COD124,SALIDA,10,2025-09-12
    COD123,SALIDA,20,2025-09-11
    COD125,ENTRADA,30,2025-09-13
    """

    File.write!("piezas.csv", piezas_content)
    File.write!("movimientos.csv", movimientos_content)

    IO.puts("Archivos CSV de ejemplo creados:")
    IO.puts("- piezas.csv")
    IO.puts("- movimientos.csv")
  end
end

# Ejecutar el programa
IO.puts("Generando archivos CSV de ejemplo...")
CSVGenerator.generate_example_files()

IO.puts("\nEjecutando programa principal...")
Main.run()
