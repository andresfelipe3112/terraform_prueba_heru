

CONSEGUIR EL TOKEN

```bash
curl -X POST http://localhost:3002/auth/generate-token \
  -H "Content-Type: application/json" \
  -d '{"userId": "123", "role": "admin"}'
```

Solo debes **reemplazar**:

* `<TU_TOKEN>` → por tu token JWT real.
* `<PRODUCT_ID>` → por el ID del producto que desees consultar o eliminar.

---

## ✅ 1. Crear un producto

```bash
curl -X POST http://localhost:3000/products \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <TU_TOKEN>" \
-d '{
  "name": "Wireless Headphones",
  "brand": "Sony",
  "offer": "Back to School",
  "description": "Noise cancelling wireless headphones",
  "about": "Long battery life, high-quality sound, Bluetooth 5.0",
  "quantity": 100,
  "rating": 4.7,
  "discount": 20,
  "salePrice": 99.99,
  "offerPrice": 79.99,
  "gender": "unisex",
  "categories": ["electronics", "audio"],
  "colors": ["black", "gray"],
  "popularity": 7451239876543210,
  "date": 5095120166338555,
  "isStock": true,
  "isNew": 30,
  "image": "https://images.unsplash.com/photo-1580894908361-967195033eae"
}'
```

---

## ✅ 2. Obtener todos los productos

```bash
curl -X GET http://localhost:3000/products \
-H "Authorization: Bearer <TU_TOKEN>"
```

---

## ✅ 3. Obtener productos por filtro (por ejemplo, por marca)

```bash
curl -X GET "http://localhost:3000/products?brand=Sony" \
-H "Authorization: Bearer <TU_TOKEN>"
```

Puedes cambiar `brand=Sony` por cualquier otro campo, por ejemplo:

```bash
/products?isStock=true
/products?categories=electronics
/products?gender=unisex
```

---

## ✅ 4. Obtener un producto específico por ID

```bash
curl -X GET http://localhost:3000/products/<PRODUCT_ID> \
-H "Authorization: Bearer <TU_TOKEN>"
```

---

## ✅ 5. Eliminar un producto por ID

```bash
curl -X DELETE http://localhost:3000/products/<PRODUCT_ID> \
-H "Authorization: Bearer <TU_TOKEN>"
```

---

¿Quieres también un ejemplo para **actualizar** (`PUT` o `PATCH`) un producto?
