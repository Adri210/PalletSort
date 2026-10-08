# IA de detecção e contagem de pallets

Esta primeira etapa cria um detector de uma classe: `pallet`. Cada caixa detectada
representa um pallet visível, portanto a contagem é o número de caixas após o filtro
de confiança e de sobreposição.

## Diagnóstico dos datasets encontrados

- `paletesAvariados/warehouse.v1i.yolov8`: 12.248 imagens com anotações de
  `forklift`, `pallet`, `pallet_truck`, `small_load_carrier` e `stillage`.
  Apesar do nome da pasta, não há uma classe de avaria. As anotações são polígonos.
- `Paletes/dataset/dataset`: 5.593 imagens sem arquivos de anotação. Elas não podem
  entrar diretamente no treinamento de detecção porque pallets presentes seriam
  tratados incorretamente como fundo.

O preparador mantém somente `pallet`, converte seus polígonos em bounding boxes e
retém uma pequena amostra de imagens negativas. Os arquivos originais não são
alterados.

Resultado validado da preparação:

- treino: 10.040 imagens e 237.422 caixas;
- validação: 1.199 imagens e 32.307 caixas;
- teste: 232 imagens e 6.389 caixas;
- total: 11.471 imagens e 276.118 caixas;
- nenhum erro de anotação e nenhum grupo de origem repetido entre os splits.

## 1. Preparar os dados

Na raiz do projeto:

```powershell
python ml/scripts/prepare_pallet_dataset.py
```

Se o Python não estiver no PATH, use o executável do ambiente virtual do backend.
O resultado fica em `ml/data/pallet_detection`, que é ignorado pelo Git.

Valide a integridade e gere amostras com as caixas convertidas:

```powershell
python ml/scripts/validate_pallet_dataset.py
python ml/scripts/preview_pallet_dataset.py
```

## 2. Criar o ambiente de treinamento

```powershell
py -m venv ml/.venv
ml/.venv/Scripts/python.exe -m pip install --upgrade pip
ml/.venv/Scripts/python.exe -m pip install -r ml/requirements.txt
```

## 3. Fazer um teste curto

```powershell
ml/.venv/Scripts/python.exe ml/scripts/train_pallet_detector.py --smoke-test --batch 2
```

Esse teste usa 2% do conjunto por uma época e grava o resultado separado em
`ml/runs/pallet_detector_smoke`.

O pipeline já foi verificado em CPU de ponta a ponta. O peso dessa execução serve
apenas para provar que treino, validação e inferência funcionam; uma época em 2% dos
dados não produz precisão suficiente para uso real.

## 4. Treinar o modelo

```powershell
ml/.venv/Scripts/python.exe ml/scripts/train_pallet_detector.py --epochs 100 --batch -1
```

O melhor peso será salvo em `ml/runs/pallet_detector/weights/best.pt`. Em uma
máquina sem GPU NVIDIA, o treinamento completo pode levar muitas horas; nesse caso,
use uma GPU em nuvem ou uma máquina de treinamento.

## 5. Detectar e contar

```powershell
ml/.venv/Scripts/python.exe ml/scripts/count_pallets.py "caminho/para/foto.jpg"
```

O comando imprime JSON com `pallet_count` e salva a imagem marcada em
`ml/outputs/pallet_counts`.

## Próxima etapa: avarias

As imagens de avaria precisam receber caixas da classe `damage`, seguindo
`ANNOTATION_GUIDE.md`. Depois, o treinamento pode usar as classes `pallet` e
`damage` do arquivo `configs/pallet_damage_TEMPLATE.yaml`.

## Licenças

O dataset anotado informa licença CC BY 4.0 e exige atribuição. Ultralytics YOLO é
AGPL-3.0 por padrão; aplicações privadas ou comerciais podem exigir licença
Enterprise. Confirme as condições antes de colocar o modelo em produção.

- Treinamento oficial: https://docs.ultralytics.com/modes/train/
- Predição oficial: https://docs.ultralytics.com/modes/predict/
- Licença Ultralytics: https://www.ultralytics.com/license
