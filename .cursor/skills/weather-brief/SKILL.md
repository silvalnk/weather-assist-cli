---
name: weather-brief
description: Consulta a temperatura atual de uma cidade com weather-assist e Open-Meteo. Use quando o usuário pedir clima, temperatura, sensação térmica ou o tempo em uma cidade.
---

# Weather brief

Nunca inventar temperatura. A única fonte é a saída da CLI.

## Workflow

1. Trabalhar na raiz de `weather_assist_cli`.
2. Rodar `ruby bin/weather-assist now "<cidade>"`.
3. Responder em português com a cidade, os °C, a sensação térmica e a condição **iguais à saída**.
4. Se o comando falhar, mostrar o erro e parar. Não estimar o clima.

## Comando

```bash
ruby bin/weather-assist now "São Paulo"
ruby bin/weather-assist now --city "Rio de Janeiro"
```
