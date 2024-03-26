# Zythologue-AME

Lister les bières par taux d'alcool, de la plus légère à la plus forte.

```
SELECT * FROM public.beer
ORDER BY beer_abv ASC
```

Afficher le nombre de bières par catégorie

```
SELECT c.category_name, COUNT(cb.beer_id) AS nombre_de_bieres
FROM category_beer cb
JOIN category c ON cb.category_id = c.category_id
GROUP BY c.category_name;
```

Trouver toutes les bières d'une brasserie donnée.
```
SELECT b.beer_name
FROM beer b
JOIN brewery br ON b.brewery_id = br.brewery_id
WHERE br.brewery_name = 'Littel-Kshlerin';
```

Lister les utilisateurs et le nombre de bières qu'ils ont ajoutées à leurs favoris.
```
SELECT bl.beerlover_name, COUNT(f.beer_id) AS nombre_de_bieres_favorites
FROM beerlover bl
LEFT JOIN favorite f ON bl.beerlover_id = f.beerlover_id
GROUP BY bl.beerlover_name;
```

Ajouter une nouvelle bière à la base de données.
```
INSERT INTO beer (beer_name, beer_description, beer_abv, brewery_id)
VALUES ('8.6', 'Une délicieuse bière brassée avec soin. Idéale pour boire sur le parking de Carrefour', 8.6, 55);
```

Afficher les bières et leurs brasseries, ordonnées par pays de la brasserie.
```
SELECT b.beer_name, br.brewery_name, br.brewery_country
FROM beer b
JOIN brewery br ON b.brewery_id = br.brewery_id
ORDER BY br.brewery_country;
```

Lister les bières avec leurs ingrédients.
```
SELECT b.beer_name, STRING_AGG(i.ingredient_name, ', ') AS ingredients
FROM beer b
LEFT JOIN beer_ingredient bi ON b.beer_id = bi.beer_id
LEFT JOIN ingredient i ON bi.ingredient_id = i.ingredient_id
GROUP BY b.beer_name;
```

Afficher les brasseries et le nombre de bières qu'elles produisent, pour celles ayant plus de 5 bières.
```
SELECT br.brewery_name, COUNT(b.beer_id) AS nombre_de_bieres
FROM brewery br
JOIN beer b ON br.brewery_id = b.brewery_id
GROUP BY br.brewery_name
HAVING COUNT(b.beer_id) > 5;
```

Lister les bières qui n'ont pas encore été ajoutées aux favoris par aucun utilisateur.
```
SELECT b.beer_name
FROM beer b
LEFT JOIN favorite f ON b.beer_id = f.beer_id
WHERE f.beer_id IS NULL;
```

Trouver les bières favorites communes entre deux utilisateurs.
```
SELECT f.beer_id, b.beer_name
FROM favorite f
JOIN beer b ON f.beer_id = b.beer_id
WHERE f.beerlover_id IN (1, 16)
GROUP BY f.beer_id, b.beer_name
HAVING COUNT(DISTINCT f.beerlover_id) = 2;
```

Afficher les brasseries dont les bières ont une moyenne des notes supérieure à une certaine valeur.
```
SELECT br.brewery_id, br.brewery_name, AVG(r.review_note) AS moyenne_notes
FROM brewery br
JOIN beer b ON br.brewery_id = b.brewery_id
LEFT JOIN review r ON b.beer_id = r.beer_id
GROUP BY br.brewery_id, br.brewery_name
HAVING AVG(r.review_note) > 2.5;
```

Mettre à jour les informations d'une brasserie.
```
UPDATE brewery
SET brewery_name = 'Brasserie Goudale',
    brewery_country = 'Belgique'
WHERE brewery_id = 1;
```

Supprimer les photos d'une bière en particulier
```
DELETE FROM photo
WHERE beer_id = 1;
```

Ecrire une procédure stockée pour permettre à un utilisateur de noter une bière. Si l'utilisateur a déjà noté cette bière, la note est mise à jour ; sinon, une nouvelle note est ajoutée.
```
CREATE OR REPLACE PROCEDURE note_biere(
    IN p_beer_id INT,
    IN p_beerlover_id INT,
    IN p_note INT,
    IN p_review_comment VARCHAR(500)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Vérifier si l'utilisateur a déjà noté cette bière
    IF EXISTS (SELECT 1 FROM review WHERE beer_id = p_beer_id AND beerlover_id = p_beerlover_id) THEN
        -- Mettre à jour la note existante
        UPDATE review
        SET review_note = p_note,
            review_comment = p_review_comment
        WHERE beer_id = p_beer_id AND beerlover_id = p_beerlover_id;
    ELSE
        -- Ajouter une nouvelle note
        INSERT INTO review (review_note, beer_id, beerlover_id, review_comment)
        VALUES (p_note, p_beer_id, p_beerlover_id, p_review_comment);
    END IF;
END;
$$;
```

Ecrire un déclencheur qui permet de détecter si l'ABV (taux d'alcool) est bien compris entre 0 et 20 avant l'ajout de chaque bière
```
CREATE OR REPLACE FUNCTION check_abv_range()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.beer_abv < 0 OR NEW.beer_abv > 20 THEN
        RAISE EXCEPTION 'Le taux d''alcool (ABV) doit être compris entre 0 et 20.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER abv_range_trigger
BEFORE INSERT ON beer
FOR EACH ROW
EXECUTE FUNCTION check_abv_range();
```
