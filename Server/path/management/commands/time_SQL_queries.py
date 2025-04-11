import time
from django.core.management.base import BaseCommand
from django.db import connection
from path import spatial_database_queries as sp

# [long1,lat1,long2,lat2, distance]
_test_data = [
    [73.35875899999999, 22.6843011, 73.9961854, 18.5610789, 453187.70012928086],
    [73.35875899999999, 22.6843011, 75.9917895, 20.88684, 330956.4543508555],
    [73.35875899999999, 22.6843011, 72.47064379999999, 22.9669356, 94534.468323121],
    [70.7916122, 22.2523996, 73.0377602, 18.999006299999998, 421972.8949008245],
    [73.9114866, 17.6799253, 73.2905674, 22.2665673, 503285.5826486402],
    [74.24930979999999, 16.7037706, 75.445853, 19.822419099999998, 362297.15028858185],
    [73.8837351, 15.5753224, 73.9961854, 18.5610789, 326578.6131063777],
    [73.35875899999999, 22.6843011, 75.445853, 19.822419099999998, 376813.00757052866],
    [74.08917819999999, 18.555028699999998, 73.9961854, 18.5610789, 9690.980212073991],
    [70.7907188, 22.264263399999997, 73.2905674, 22.2665673, 252751.82649861719],
    [73.8260678, 15.6002649, 73.8282141, 15.4989946, 11107.377345240053],
    [73.8260883, 15.600258, 73.8119741, 15.5926511, 1716.1941408170815],
]


def test1():
    # With no filtering and no index
    query = """WITH input as (SELECT %s AS source_id, %s AS target_id),
            dr as (
            select * FROM pgr_dijkstra(
            'SELECT id_new as id, source, target, 
            CASE 
            WHEN e.car_forward <> ''Forbidden'' then length::double precision 
            ELSE -1 
            END as cost, 
            CASE 
            WHEN e.car_backward <> ''Forbidden'' then length::double precision 
            ELSE -1 
            END as reverse_cost  
            FROM public.edges as e', 
            (select source_id from input),
            (select target_id from input))
            )
            SELECT
            dr.path_seq AS path_seq, 
            e.length::double precision AS length,
            SUM(e.length::double precision ) OVER (ORDER BY dr.path_seq) AS aggr_length,
            CASE WHEN dr.node = e.source THEN e.wkt ELSE ST_AsText(ST_Reverse(e.geom_way)) END AS wkt
            from 
            dr, edges  AS e where e.id_new = dr.edge 
            order by path_seq asc;"""
    return query


def test2():
    # With no filtering and no index
    query = """WITH input as (SELECT %s AS source_id, %s AS target_id),
            box AS (SELECT ST_Expand(ST_Extent(geom_way), 0.1) as box from edges as b, input
                    WHERE b.source = input.source_id OR b.source = input.target_id
                    OR b.target = input.source_id OR b.target= input.target_id
                ),
            dr as (
            select * FROM pgr_dijkstra(
            'SELECT id_new as id, source, target, 
            CASE 
            WHEN e.car_forward <> ''Forbidden'' then length::double precision 
            ELSE -1 
            END as cost, 
            CASE 
            WHEN e.car_backward <> ''Forbidden'' then length::double precision 
            ELSE -1 
            END as reverse_cost  
            FROM public.edges as e
            WHERE e.geom_way && ST_GeomFromText(''' ||(select ST_AsText(box) from box)|| ''', 4326)
            ', 
            (select source_id from input),
            (select target_id from input))
            )
            SELECT
            dr.path_seq AS path_seq, 
            e.length::double precision AS length,
            SUM(e.length::double precision ) OVER (ORDER BY dr.path_seq) AS aggr_length,
            CASE WHEN dr.node = e.source THEN e.wkt ELSE ST_AsText(ST_Reverse(e.geom_way)) END AS wkt
            from 
            dr, edges  AS e where e.id_new = dr.edge 
            order by path_seq asc;"""
    return query


class Command(BaseCommand):
    help = "Time the SQL queries"
    # Pregenerated from __init__
    node_ids = [
        (6149903796, 8005877231),
        (6149903796, 8187161647),
        (6149903796, 11259695669),
        (9753639371, 9828146304),
        (7980166646, 8500629842),
        (4086312300, 7904668060),
        (2638786859, 8005877231),
        (6149903796, 7904668060),
        (2269342967, 8005877231),
        (3766860262, 8500629842),
        (2574700761, 4081435280),
        (2574700761, 9157430447),
    ]
    # Uncomment if changes are made to _test_data
    # def __init__(self):
    #     for data in _test_data:
    #         self.node_ids.append(sp.get_nodes_from_longlat(*data[:-1]))
    #     print(self.node_ids)

    def handle(self, *args, **kwargs):
        query = test2()
        query_times = []
        for pair in self.node_ids:
            print(pair)
            start_time = time.time()
            with connection.cursor() as cursor:
                cursor.execute(query, list(pair))
                result = cursor.fetchall()
            end_time = time.time()
            duration = end_time - start_time
            query_times.append(duration)
        print(query_times)


# test1
# [14.9069504737854, 11.811800241470337, 11.445417881011963, 12.10834264755249, 12.18774127960205, 12.09599232673645, 11.938441038131714,
# 12.31855297088623, 11.622976541519165, 12.041283369064331, 11.615197658538818, 11.511570692062378]


# test2
# [5.890808820724487, 5.234128713607788, 5.361343860626221, 3.2586326599121094, 5.934058666229248, 5.659358263015747, 2.3801074028015137,
# 5.707026481628418, 5.283438205718994, 2.4020628929138184, 5.075456380844116, 4.937410116195679]

# test2 with index on geom_way
# [5.1723620891571045, 4.406029224395752, 4.369088888168335, 2.404144525527954, 5.041927814483643, 4.675012111663818, 1.4043035507202148,
# 4.7420814037323, 4.05539608001709, 1.270747184753418, 3.9638774394989014, 3.7508010864257812]

# test2 with index on geom_way, id_new, (source, target)
# [2.082576036453247, 1.4528625011444092, 0.5254619121551514, 2.4404664039611816, 2.104205369949341, 1.851039171218872, 1.5579712390899658,
# 1.7463266849517822, 0.3062310218811035, 1.4445898532867432, 0.21879816055297852, 0.19959282875061035]
