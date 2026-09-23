---
inclusion: always
---

# Estrutura

- `bin/weather-assist` — entrypoint.
- `lib/cli.rb` — subcomando `now` e flags.
- `lib/client.rb` — geocoding e forecast.
- `lib/codes.rb` — códigos WMO para texto curto.
- `test/client_test.rb` — parse, códigos e CLI com HTTP injetado.
- `.cursor/` — skills e subagentes do Cursor.
- `.kiro/` — steering, skills e agentes do Kiro.
