import time
from django.core.management.base import BaseCommand
from django.db import connection, transaction, DatabaseError
from path import spatial_database_queries as sp

class Command(BaseCommand):
    help = "Test deleting records from anomalies tables"
    def handle(self, *args, **kwargs):

        lng=73.826105
        lat=15.600998
        cid=1
        with transaction.atomic():
            with connection.cursor() as cursor:
                try:
                    cursor.execute("BEGIN;")
                    
                    ids = sp.get_ids_of_potential_anomalies(lng, lat, cid)
                    print("IDs: ", ids, len(ids))
                    
                    cursor.execute("SELECT COUNT(*) FROM potential_anomaly")                    
                    (cnt_before,) = cursor.fetchone()
                    print("cnt_before",cnt_before)
                    # cursor.execute("SELECT 1 FROM mv_clustered_anomalies WHERE unique_id = %s", [cid])
                    # result = cursor.fetchall()
                    # print(result)

                    sp.delete_from_potential_anomaly(ids)
                    
                    
                    
                    
                    cursor.execute("SELECT COUNT(*) FROM potential_anomaly")
                    (cnt_after,) = cursor.fetchone()
                    print("cnt_after",cnt_after)
                    
                    # cursor.execute("") 
                    # cursor.execute("SELECT 1 FROM mv_clustered_anomalies WHERE unique_id = %s", [cid])
                    # result_2 = cursor.fetchall()
                    # print(result_2)
                    # ids_2 = sp.get_ids_of_potential_anomalies(lng, lat, cid)
                    # print(len(ids))
                    
                    cursor.execute("ROLLBACK;")
                except Exception as e:
                    print(e)
                
        with transaction.atomic():
            with connection.cursor() as cursor:
                cursor.execute("SELECT COUNT(*) FROM potential_anomaly")
                (cnt_after_rollback,) = cursor.fetchone()
                print("cnt_after_rollback",cnt_after_rollback)