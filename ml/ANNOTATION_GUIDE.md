# Guia de anotação: pallets e avarias

## Classe `pallet`

- Desenhe uma caixa ao redor de cada pallet visível, mesmo carregado.
- Inclua toda a estrutura visível do pallet, sem incluir a carga.
- Pallets muito ocluídos podem ser anotados quando a estrutura ainda for reconhecível.
- Não anote carrinhos, caixas plásticas, gaiolas ou empilhadeiras como pallet.

## Classe `damage`

- Desenhe uma caixa justa somente na área avariada.
- Inclua tábua quebrada ou ausente, bloco rompido, peça solta e deformação estrutural.
- Não marque sujeira, pintura, etiqueta ou desgaste superficial como avaria estrutural.
- Uma imagem pode conter várias avarias dentro de um mesmo pallet.

Para informar quantos pallets estão avariados, a inferência associa uma caixa `damage`
ao pallet que a contém. O dataset atual ainda não possui essas caixas; elas precisam
ser revisadas por uma pessoa que conheça o critério operacional de avaria.

Não misture fotos do mesmo pallet ou da mesma sequência de vídeo entre treino e
validação. Isso causaria vazamento de dados e métricas artificialmente altas.
