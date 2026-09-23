# weather-assist

CLI Ruby que mostra a temperatura atual de uma cidade. A fonte é a [Open-Meteo](https://open-meteo.com/), sem chave de API. Só biblioteca padrão (Ruby 3.2 ou mais recente).

## Uso

Na raiz deste diretório:

```bash
ruby bin/weather-assist now "São Paulo"
ruby bin/weather-assist now --city "Rio de Janeiro"
```

Saída (inglês):

```text
São Paulo, Brasil
22.4 °C (feels like 21.1 °C)
Clear
```

Testes, sem rede:

```bash
ruby -Ilib test/client_test.rb
```

## Cursor

Skills e subagentes ficam neste repositório.

- `/weather-brief` — consulta a temperatura e responde com a saída real da CLI.
- `/weather-cli` — ao mudar o comando `now`, a Open-Meteo ou as unidades.
- Subagente `weather-briefer` — delegue quando a pergunta for só o clima de uma cidade.
- Subagente `weather-verifier` — roda os testes e um `now` ao vivo em São Paulo.

O briefing de sessão está em `AGENTS.md`.

## Kiro

O mesmo `AGENTS.md` entra como steering. O restante fica em `.kiro/`:

- Steering sempre incluído: `.kiro/steering/product.md`, `tech.md`, `structure.md`.
- Skills: `/weather-brief` e `/weather-cli` (também ativam pela descrição).
- Agentes: escolha `weather-briefer` ou `weather-verifier` no seletor da sessão. Eles carregam o steering e as skills pelos `resources`.

Documentação: [steering](https://kiro.dev/docs/steering/), [skills](https://kiro.dev/docs/skills/), [agentes](https://kiro.dev/docs/custom-agents/creating/).
