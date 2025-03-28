# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.SmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class Nodes(models.Model):
    id = models.BigIntegerField(primary_key=True)
    longitude = models.FloatField(blank=True, null=True)
    latitude = models.FloatField(blank=True, null=True)
    
    geom = models.GeometryField(editable=False) #Generated column 
    
    class Meta:
        managed = False
        db_table = 'nodes'


class Edges(models.Model):
    id = models.TextField(blank=True, null=True)
    osm_id = models.BigIntegerField(blank=True, null=True)
    source = models.ForeignKey('Nodes', models.DO_NOTHING, db_column='source', blank=True, null=True)
    target = models.ForeignKey('Nodes', models.DO_NOTHING, db_column='target', related_name='edges_target_set', blank=True, null=True)
    length = models.FloatField(blank=True, null=True)
    foot = models.TextField(blank=True, null=True)  # This field type is a guess.
    car_forward = models.TextField(blank=True, null=True)  # This field type is a guess.
    car_backward = models.TextField(blank=True, null=True)  # This field type is a guess.
    bike_forward = models.TextField(blank=True, null=True)  # This field type is a guess.
    bike_backward = models.TextField(blank=True, null=True)  # This field type is a guess.
    train = models.TextField(blank=True, null=True)  # This field type is a guess.
    wkt = models.TextField(blank=True, null=True)
    
    id_new = models.BigIntegerField(primary_key=True, editable=False)
    geom_way = models.GeometryField(editable=False)  
    class Meta:
        managed = False
        db_table = 'edges'

class PotentialAnomaly(models.Model):
    id = models.BigIntegerField(primary_key=True)
    longitude = models.FloatField(blank=True, null=True)
    latitude = models.FloatField(blank=True, null=True)
    
    a_type = models.TextField(blank=True, null=True)  # This field type is a guess.
    confidence = models.FloatField(blank=True, null=True)
    
    geom = models.GeometryField(editable=False)  # This field type is a guess.
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'potential_anomaly'

class MvClusteredAnomalies(models.Model):
    # Value won't survie after refresh use location data to select  
    unique_id = models.BigIntegerField(primary_key=True, editable=False) 
    
    
    total_confidence = models.FloatField( editable=False)
    a_type = models.CharField(max_length=255, editable=False)
    point_ids = models.JSONField( editable=False)  
    point_count = models.IntegerField( editable=False)
    p_geom = models.GeometryField( editable=False)
    edge_id = models.ForeignKey('Edges', models.DO_NOTHING, db_column='edge_id', editable=False)

    class Meta:
        managed = False  
        db_table = 'mv_clustered_anomalies'  


class SpatialRefSys(models.Model):
    srid = models.IntegerField(primary_key=True)
    auth_name = models.CharField(max_length=256, blank=True, null=True)
    auth_srid = models.IntegerField(blank=True, null=True)
    srtext = models.CharField(max_length=2048, blank=True, null=True)
    proj4text = models.CharField(max_length=2048, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'spatial_ref_sys'
