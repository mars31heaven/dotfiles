#!/bin/bash

# Configurações de Arquivos
INPUT_LOGO="seu_logo_459.png" # Certifique-se de que o arquivo está na pasta
PREFIX="cartela_final"
TEMP_TEXT="temp_text.png"
TEMP_BUFFER="temp_buffer.txt"

# Dimensões e Estilo
WIDTH=1080
HEIGHT=1920
PADDING=120
TEXT_WIDTH=$((WIDTH - 2 * PADDING))
BG_COLOR="black"
FONT_COLOR="white"
FONT_SIZE=85
FONT_NAME="Roboto-Bold"

# 1. Encontrar próximo número
COUNT=1
while [ -f "${PREFIX}_$(printf "%02d" $COUNT).png" ]; do
    COUNT=$((COUNT + 1))
done
FILENAME="${PREFIX}_$(printf "%02d" $COUNT).png"

# 2. Edição do texto no Neovim
nvim $TEMP_BUFFER
if [ ! -s $TEMP_BUFFER ]; then echo "Vazio. Abortando."; exit 1; fi

echo "Renderizando $FILENAME com imagem..."

# 3. Criar o bloco de texto (com altura dinâmica)
magick -size ${TEXT_WIDTH}x \
    -background ${BG_COLOR} \
    -fill ${FONT_COLOR} \
    -font "${FONT_NAME}" \
    -pointsize ${FONT_SIZE} \
    -gravity Center \
    -interline-spacing 15 \
    caption:"$(cat $TEMP_BUFFER)" \
    $TEMP_TEXT

# 4. Combinar Texto + Espaço + Imagem
# O comando 'append' junta imagens verticalmente (-append)
# Adicionamos um pequeno espaçamento (canvas preto de 100px de altura) entre eles
magick -size ${WIDTH}x100 xc:${BG_COLOR} temp_spacer.png

magick -background ${BG_COLOR} \
    -gravity Center \
    $TEMP_TEXT \
    temp_spacer.png \
    "$INPUT_LOGO" \
    -append \
    -gravity Center \
    -extent ${WIDTH}x${HEIGHT} \
    "$FILENAME"

# 5. Limpeza
rm $TEMP_BUFFER $TEMP_TEXT temp_spacer.png
echo "Sucesso! Criado: $FILENAME"
