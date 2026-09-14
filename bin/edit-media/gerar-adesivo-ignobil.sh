#!/bin/bash

INPUT="seu_logo.png"
OUTPUT_PDF="adesivos_ignobil_final.pdf"
DPI=300

# 1. Dimensões A4 em pixels (300 DPI)
A4_W=2480
A4_H=3508

# 2. Largura de 10cm em pixels
TARGET_W=1181

echo "Redimensionando e montando folha..."

# Redimensiona o logo original
magick "$INPUT" -resize ${TARGET_W}x temp_logo.png

# 3. Cria a folha branca e cola os logos em posições exatas (6 linhas x 2 colunas)
# X=50 e X=1250 deixam margens de segurança laterais de aprox. 4mm
magick -size ${A4_W}x${A4_H} xc:white \
    -draw "image over 50,50 0,0 'temp_logo.png'" \
    -draw "image over 1250,50 0,0 'temp_logo.png'" \
    -draw "image over 50,600 0,0 'temp_logo.png'" \
    -draw "image over 1250,600 0,0 'temp_logo.png'" \
    -draw "image over 50,1150 0,0 'temp_logo.png'" \
    -draw "image over 1250,1150 0,0 'temp_logo.png'" \
    -draw "image over 50,1700 0,0 'temp_logo.png'" \
    -draw "image over 1250,1700 0,0 'temp_logo.png'" \
    -draw "image over 50,2250 0,0 'temp_logo.png'" \
    -draw "image over 1250,2250 0,0 'temp_logo.png'" \
    -draw "image over 50,2800 0,0 'temp_logo.png'" \
    -draw "image over 1250,2800 0,0 'temp_logo.png'" \
    -density $DPI -units PixelsPerInch "$OUTPUT_PDF"

rm temp_logo.png
echo "PDF Gerado: $OUTPUT_PDF"
