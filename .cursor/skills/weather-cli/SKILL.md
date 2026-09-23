---
name: weather-cli
description: Altera a CLI weather-assist (comando now, Open-Meteo, unidades, códigos WMO) mantendo o contrato e os testes de parse. Use ao mudar o cliente HTTP, o comando now ou o formato de saída.
---

# Weather CLI

Ruby `>= 3.2`, só biblioteca padrão. Sem gem e sem chave de API.

## Contrato

- Comando: `ruby bin/weather-assist now [--city CITY] [CITY]`
- Geocoding: `https://geocoding-api.open-meteo.com/v1/search` (`name`, `count=1`, `language=pt`)
- Forecast: `https://api.open-meteo.com/v1/forecast` com `current=temperature_2m,apparent_temperature,weather_code` e `timezone=auto`
- Saída em inglês: cidade resolvida, °C, sensação térmica, condição curta (`Clear`, `Rain`, …)
- Erros em inglês no stderr: cidade ausente, rede, JSON inesperado

## Ao mudar comportamento

1. Ajustar `lib/` e os testes em `test/client_test.rb` com JSON fixo, sem rede.
2. Rodar `ruby -Ilib test/client_test.rb`.
3. Atualizar `README.md` e `AGENTS.md` se o comando ou a saída mudar.
