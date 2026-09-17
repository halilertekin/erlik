#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "🐺 ERLİK NPM Publish Hazırlanıyor..."

# 1. NPM Kimlik Kontrolü
USER=$(npm whoami --registry https://registry.npmjs.org/ 2>/dev/null || echo "")
if [ -z "$USER" ]; then
    echo "❌ NPM oturumu bulunamadı. Lütfen önce 'npm login' yapın."
    exit 1
fi
echo "👤 NPM Kullanıcısı: $USER"

# 2. Dry run testi
echo "🧪 Paket doğrulanıyor (dry-run)..."
npm publish --dry-run --registry https://registry.npmjs.org/

# 3. Gerçek publish
echo "🚀 NPM Registry'e yükleniyor..."
npm publish --access public --registry https://registry.npmjs.org/

echo "✅ ERLİK başarıyla NPM'de yayınlandı!"
echo "📦 https://www.npmjs.com/package/erlik"
