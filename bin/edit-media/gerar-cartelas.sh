#!/bin/bash

# Dimensões Vertical (9:16)
WIDTH=1080
HEIGHT=1920
PADDING=120  # Margem de segurança para interface de redes sociais
TEXT_WIDTH=$((WIDTH - 2 * PADDING))

# Estilo
BG_COLOR="black"
FONT_COLOR="white"
FONT_SIZE=85
FONT_NAME="Roboto-Bold"

# Gerenciamento de Arquivos
TEMP_FILE="temp_buffer.txt"
PREFIX="cartela"

# 1. Encontrar o próximo número disponível (cartela_01, cartela_02, etc)
COUNT=1
while [ -f "${PREFIX}_$(printf "%02d" $COUNT).png" ]; do
    COUNT=$((COUNT + 1))
done

FILENAME="${PREFIX}_$(printf "%02d" $COUNT).png"

# 2. Interface no Neovim
echo "-- EDITANDO: $FILENAME --"
sleep 1
nvim $TEMP_FILE

# Verifica se houve conteúdo
if [ ! -s $TEMP_FILE ]; then
    echo "Cancelado: Arquivo vazio."
    exit 1
fi

# 3. Geração da Imagem com ImageMagick
echo "Renderizando $FILENAME..."

magick -size ${TEXT_WIDTH}x \
    -background ${BG_COLOR} \
    -fill ${FONT_COLOR} \
    -font "${FONT_NAME}" \
    -pointsize ${FONT_SIZE} \
    -gravity Center \
    -interline-spacing 15 \
    caption:"$(cat $TEMP_FILE)" \
    -background ${BG_COLOR} \
    -gravity Center \
    -extent ${WIDTH}x${HEIGHT} \
    "${FILENAME}"

# 4. Limpeza e Finalização
rm $TEMP_FILE
echo "Sucesso! Criado: $FILENAME"
