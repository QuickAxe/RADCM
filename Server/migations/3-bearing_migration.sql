-- Add this geenrated tables to speed up the query.

ALTER TABLE edges
	ADD COLUMN 
	bearing1 float 
	GENERATED ALWAYS 
	AS (
        ST_Azimuth(
		ST_PointN(edges.wkt, 1), 
		ST_PointN(edges.wkt, 2)
		)
    )
	STORED;





ALTER TABLE edges
	ADD COLUMN 
	bearing2 float 
	GENERATED ALWAYS 
	AS (ST_Azimuth(
		ST_PointN(edges.wkt, -1), 
		ST_PointN(edges.wkt, -2)
		))
	STORED;