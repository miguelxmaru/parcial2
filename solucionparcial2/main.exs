defmodule Main do
  def run do
    IO.puts("=== SISTEMA DE INVENTARIO ===")

    # Cargar módulos necesarios
    Code.ensure_loaded(Pieza)
    Code.ensure_loaded(Movimiento)
    Code.ensure_loaded(Inventario)
    Code.ensure_loaded(ComplejoB)

    # Procesar piezas
    IO.puts("\n1) Leyendo piezas.csv...")
    case Inventario.leer_piezas("piezas.csv") do
      {:ok, piezas} ->
        IO.puts("Piezas cargadas: #{length(piezas)}")
        mostrar_piezas_resumen(piezas)

        # Contar stock bajo
        umbral = 40
        count_bajo = Pieza.contar_stock_bajo(piezas, umbral)
        IO.puts("Piezas con stock < #{umbral}: #{count_bajo}")

        # Procesar movimientos
        IO.puts("\n2) Leyendo movimientos.csv...")
        case Inventario.leer_movimientos("movimientos.csv") do
          {:ok, movimientos} ->
            IO.puts("Movimientos cargados: #{length(movimientos)}")
            mostrar_movimientos_resumen(movimientos)

            # Aplicar movimientos
            piezas_actualizadas = Inventario.aplicar_movimientos(piezas, movimientos)
            IO.puts("\nPiezas actualizadas después de movimientos:")
            mostrar_piezas_resumen(piezas_actualizadas)

            # Guardar inventario actual
            IO.puts("\nGuardando inventario_actual.csv...")
            case Inventario.guardar_inventario(piezas_actualizadas, "inventario_actual.csv") do
              {:ok, mensaje} -> IO.puts(mensaje)
              {:error, razon} -> IO.puts("Error: #{razon}")
            end

            # Cantidad total en rango de fechas
            IO.puts("\n3) Calculando movimientos en rango de fechas...")
            fecha_ini = "2025-09-10"
            fecha_fin = "2025-09-12"
            total_movido = Movimiento.cantidad_total_en_rango(movimientos, fecha_ini, fecha_fin)
            IO.puts("Total movido entre #{fecha_ini} y #{fecha_fin}: #{total_movido}")

            # Eliminar duplicados
            IO.puts("\n4) Eliminando duplicados...")
            piezas_con_duplicados = piezas ++ [List.first(piezas)]
            piezas_sin_duplicados = Pieza.eliminar_duplicados(piezas_con_duplicados)
            IO.puts("Original: #{length(piezas_con_duplicados)}, Sin duplicados: #{length(piezas_sin_duplicados)}")

          {:error, razon} ->
            IO.puts("Error cargando movimientos: #{razon}")
        end

      {:error, razon} ->
        IO.puts("Error cargando piezas: #{razon}")
    end

    # Pruebas simples de ComplejoB
    ejecutar_punto_5()
  end

  defp ejecutar_punto_5 do
    IO.puts("\n5) PRUEBAS FUNCIÓN ComplejoB")

    # Pruebas simples
    IO.puts("Pruebas de la función ComplejoB.f(n):")
    IO.puts("")

    for n <- 0..6 do
      resultado = ComplejoB.f(n)
      IO.puts("f(#{n}) = #{resultado}")
    end

  end

  defp mostrar_piezas_resumen(piezas) do
    Enum.each(piezas, fn p ->
      IO.puts("  #{p.codigo}: #{p.nombre} - Stock: #{p.stock}")
    end)
  end

  defp mostrar_movimientos_resumen(movimientos) do
    Enum.each(movimientos, fn m ->
      tipo_str = if m.tipo == :entrada, do: "ENTRADA", else: "SALIDA"
      IO.puts("  #{m.codigo}: #{tipo_str} #{m.cantidad} - #{m.fecha}")
    end)
  end
end

# Módulo para generar archivos CSV
defmodule CSVGenerator do
  def generate_example_files do
    piezas_content = """
    COD123,Resistor,47,ohm,120
    COD124,Capacitor,100,uF,35
    COD125,Inductor,10,mH,60
    COD126,LED,5,V,25
    """

    movimientos_content = """
    COD123,ENTRADA,50,2025-09-10
    COD124,SALIDA,10,2025-09-12
    COD123,SALIDA,20,2025-09-11
    COD125,ENTRADA,30,2025-09-13
    """

    File.write!("piezas.csv", piezas_content)
    File.write!("movimientos.csv", movimientos_content)
  end
end

Main.run()
