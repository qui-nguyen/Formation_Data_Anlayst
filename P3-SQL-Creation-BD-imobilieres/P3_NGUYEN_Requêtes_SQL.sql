--1. Nombre total d’appartements vendus au 1er semestre 2020.

SELECT
	COUNT(b.id_bien) as Nb_appartements_vendus
FROM 
	bien b
	join type_bien t on b.code_type_bien = t.code_type_bien
	join vente v on v.id_bien = b.id_bien
WHERE
	t.type_bien = 'Appartement' 
	and date_mutation between cast('2020-01-01' as date) and cast('2020-06-30' as date)
;

--2. Proportion des ventes d’appartements par le nombre de pièces.

SELECT
	b.nb_pieces_princ
	,round(COUNT(v.id_vente) * 100 /
		(
		SELECT 
			COUNT(v.id_vente)
			FROM Vente v
				join Bien b on v.id_bien = b.id_bien
				join Type_bien t on b.code_type_bien = t.code_type_bien
		), 2) as Proportion 
FROM Vente v
		join Bien b on v.id_bien = b.id_bien
		join Type_bien t on b.code_type_bien = t.code_type_bien
GROUP BY 
	b.nb_pieces_princ
;

--3.Liste des 10 départements où le prix du mètre carré est le plus élevé.

SELECT 
	code_dep
	,round(AVG(valeur_fonciere/surf_carrez_1er_lot), 2) as AVG_prix
FROM 
		Parcelle p
		join Adresse a on a.id_parcelle = p.id_parcelle
		join Bien b on b.id_adresse = a.id_adresse
		join Vente v on v.id_bien = b.id_bien
GROUP BY code_dep
ORDER BY AVG_prix DESC
LIMIT 10
;

--4. Prix moyen du mètre carré d’une maison en Île-de-France.

SELECT 
	round(AVG (valeur_fonciere/surf_carrez_1er_lot), 2) as AVG_prix_maison_IDF
FROM 
		Vente v
		join Bien b on v.id_bien = b.id_bien
		join Adresse a on b.id_adresse = a.id_adresse
		join Parcelle p on a.id_parcelle = p.id_parcelle
		join Type_bien t on b.code_type_bien = t.code_type_bien
WHERE 
	p.code_dep IN ('75', '77', '78', '91', '92', '93', '94', '95')
	AND t.type_bien = 'Maison'
;

--5. Liste des 10 appartements les plus chers avec le département et le
--nombre de mètres carrés.

SELECT
	p.code_dep
	,b.surf_carrez_1er_lot
	,v.valeur_fonciere
FROM 
		Vente v
		join Bien b on v.id_bien = b.id_bien
		join Adresse a on b.id_adresse = a.id_adresse
		join Parcelle p on a.id_parcelle = p.id_parcelle
		join Type_bien t on b.code_type_bien = t.code_type_bien
WHERE
	 t.type_bien = 'Appartement'
	AND v.valeur_fonciere IS NOT NULL
ORDER BY 
	v.valeur_fonciere DESC
LIMIT 10
;

--6. Taux d’évolution du nombre de ventes entre le premier et le second
--trimestre de 2020.

WITH
	trimestre_1 as 
	(
	SELECT COUNT (id_vente) t_1 
	FROM Vente 
	WHERE date_mutation between cast('2020-01-01' as date) and cast('2020-03-31' as date)
	 )
	,trimestre_2 as 
	(
	SELECT COUNT (id_vente) t_2 
	FROM Vente 
	WHERE date_mutation between cast('2020-04-01' as date) and cast('2020-06-30' as date)
	)
SELECT 
	round(((t_2 - t_1)*100/t_1), 2) as evolution_nb_ventes
FROM trimestre_1, trimestre_2
;

--7. Liste des communes où le nombre de ventes a augmenté d'au
--moins 20% entre le premier et le second trimestre de 2020

WITH	
	trimestre_1 as 
	(
	SELECT
	p.commune, COUNT (id_vente) t_1 
	FROM vente v
		join Bien b on v.id_bien = b.id_bien
		join Adresse a on b.id_adresse = a.id_adresse
		join Parcelle p on a.id_parcelle = p.id_parcelle
		join Type_bien t on b.code_type_bien = t.code_type_bien 
	WHERE date_mutation between cast('2020-01-01' as date) and cast('2020-03-31' as date)
	GROUP BY p.commune
	)
	
	,trimestre_2 as 
	(
	SELECT 
	p.commune ,COUNT (id_vente) t_2 
	FROM vente v
		join Bien b on v.id_bien = b.id_bien
		join Adresse a on b.id_adresse = a.id_adresse
		join Parcelle p on a.id_parcelle = p.id_parcelle
		join Type_bien t on b.code_type_bien = t.code_type_bien
	WHERE date_mutation between cast('2020-04-01' as date) and cast('2020-06-30' as date)
	GROUP BY p.commune
	)
	,resultat as 
	(
	SELECT 
		t1.commune
		, round(((t_2 - t_1)/t_1)*100, 2) as taux
	FROM trimestre_1 t1 join trimestre_2 t2 on t1.commune = t2.commune
	)
	
SELECT commune, taux
FROM resultat
WHERE taux > 20
ORDER BY taux ASC
;

--8. Différence en pourcentage du prix au mètre carré entre un
--appartement de 2 pièces et un appartement de 3 pièces.

WITH 
	app_2_pcs as (
		SELECT 
		AVG (valeur_fonciere/surf_carrez_1er_lot) AVG_2_pcs
		FROM Vente v
			join Bien b on v.id_bien = b.id_bien
			join Adresse a on b.id_adresse = a.id_adresse
			join Parcelle p on a.id_parcelle = p.id_parcelle
			join Type_bien t on b.code_type_bien = t.code_type_bien
		WHERE
			nb_pieces_princ = '2'
		AND t.type_bien = 'Appartement'
		)
	,app_3_pcs as (
		SELECT 
		AVG (valeur_fonciere/surf_carrez_1er_lot) AVG_3_pcs
		FROM Vente v
			join Bien b on v.id_bien = b.id_bien
			join Adresse a on b.id_adresse = a.id_adresse
			join Parcelle p on a.id_parcelle = p.id_parcelle
			join Type_bien t on b.code_type_bien = t.code_type_bien
		WHERE
			nb_pieces_princ = '3'
		AND t.type_bien = 'Appartement'
		)
		
SELECT 
	round(((AVG_3_pcs - AVG_2_pcs) *100 / AVG_2_pcs), 2) as diff_pourc_prix_m_2
FROM
	app_2_pcs
	,app_3_pcs
;

--9. Donnez les moyennes de valeurs foncières pour le top 20 des
--communes.


SELECT
	commune
	,round (AVG (v.valeur_fonciere),2) as moyenne
FROM 
	Vente v
	join Bien b on v.id_bien = b.id_bien
	join Adresse a on b.id_adresse = a.id_adresse
	join Parcelle p on a.id_parcelle = p.id_parcelle
WHERE  
	v.valeur_fonciere IS NOT NULL
GROUP BY p.commune
ORDER BY 
	moyenne DESC
LIMIT 20
;