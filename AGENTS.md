# AGENTS.md

Briefing **independente de sessão** para o Cursor e para o Kiro. O histórico do chat é opcional; estes arquivos não.

## Sempre (sessão nova)

1. Rodar `ruby bin/weather-assist now "<cidade>"` **antes** de falar temperatura, sensação térmica ou condição do tempo.
2. Nunca inventar número. Se a CLI falhar, repetir o erro e parar.
3. Código, CLI, erros e identificadores: **inglês**. Markdown: **português**.
4. Manter o contrato do comando `now`: geocoding Open-Meteo, forecast atual em °C, sem chave e sem cache.
5. Ao mudar comportamento, atualizar os testes em `test/client_test.rb` e o README se o comando mudar.

## Produto

**weather-assist** é uma CLI Ruby (stdlib) que mostra a temperatura atual de uma cidade via [Open-Meteo](https://open-meteo.com/). Sem gem e sem API key.

## Comandos

```bash
ruby bin/weather-assist now "São Paulo"
ruby bin/weather-assist now --city "Rio de Janeiro"
ruby -Ilib test/client_test.rb
```

## Não adicionar

Chave de API, cache, previsão de vários dias, interface web, gems.
