Feature: Automatic deletion control

    Background:
        Given the grid
          | 1 |   | 2 |
          |   |   |   |
          | 3 |   | 4 |
        And the OSM data
          """
          n1 v2 Tname=N1
          n4 v1 Tname=N4
          w1 v1 Tname=W1 Nn1,n2,n4
          w2 v10 Tname=w2 Nn3,n4
          r1 v34 Ttype=site,name=R1 Mw2@foo,n3@
          r2 v1 Ttype=site,name=R2 Mn2@
          """

    Scenario Outline: Objects are deleted on delete and modify
        Given the lua style
            """
            local table = osm2pgsql.define_table{
                name = 'test', <extra>
                ids = { type = 'any', type_column = 'otype', id_column = 'oid'},
                columns = {{ column = 'version', type = 'int'}}
            }

            local function process(object)
                table:insert{version = object.version}
            end

            osm2pgsql.process_node = process
            osm2pgsql.process_way = process
            osm2pgsql.process_relation = process
            """
        When running osm2pgsql flex with parameters
            | --slim |
        Then table test contains exactly
            | otype | oid | version |
            | N     | 1   | 2       |
            | N     | 4   | 1       |
            | W     | 1   | 1       |
            | W     | 2   | 10      |
            | R     | 1   | 34      |
            | R     | 2   | 1       |
        Given the grid
            | 1 |   |   |
            |   | 5 | 4 |
            |   |   |   |
        And the OSM data
            """
            n1 v3 dD
            n4 v2 Tname=N4
            n5 v1 Tname=N5
            w1 v2 dD
            r1 v35 dD
            r2 v2 Ttype=site,name=R2b Mn2@
            """
        When running osm2pgsql flex with parameters
            | --slim | --append |
        Then table test contains exactly
            | otype | oid | version |
            | N     | 4   | 2       |
            | N     | 5   | 1       |
            | W     | 2   | NULL    |
            | R     | 2   | 2       |

        Examples:
            | extra |
            | |
            | auto_delete = 'delete,modify', |
            | auto_delete = 'modify,delete', |


    Scenario: Deleting objects can be disabled
        Given the lua style
            """
            local table = osm2pgsql.define_table{
                name = 'test',
                auto_delete = 'modify',
                ids = { type = 'any', type_column = 'otype', id_column = 'oid'},
                columns = {{ column = 'version', type = 'int'}}
            }

            local function process(object)
                table:insert{version = object.version}
            end

            osm2pgsql.process_node = process
            osm2pgsql.process_way = process
            osm2pgsql.process_relation = process
            """
        When running osm2pgsql flex with parameters
            | --slim |
        Given the grid
            | 1 |   |   |
            |   | 5 | 4 |
            |   |   |   |
        And the OSM data
            """
            n1 v3 dD
            n4 v2 Tname=N4
            n5 v1 Tname=N5
            w1 v2 dD
            r1 v35 dD
            r2 v2 Ttype=site,name=R2b Mn2@
            """
        When running osm2pgsql flex with parameters
            | --slim | --append |
        Then table test contains exactly
            | otype | oid | version |
            | N     | 1   | 2       |
            | N     | 4   | 2       |
            | N     | 5   | 1       |
            | W     | 1   | 1       |
            | W     | 2   | NULL    |
            | R     | 1   | 34      |
            | R     | 2   | 2       |


    Scenario: Deleting objects on modification can be disabled
        Given the lua style
            """
            local table = osm2pgsql.define_table{
                name = 'test',
                auto_delete = 'delete',
                ids = { type = 'any', type_column = 'otype', id_column = 'oid'},
                columns = {{ column = 'version', type = 'int'}}
            }

            local function process(object)
                table:insert{version = object.version}
            end

            osm2pgsql.process_node = process
            osm2pgsql.process_way = process
            osm2pgsql.process_relation = process
            """
        When running osm2pgsql flex with parameters
            | --slim |
        Given the grid
            | 1 |   |   |
            |   | 5 | 4 |
            |   |   |   |
        And the OSM data
            """
            n1 v3 dD
            n4 v2 Tname=N4
            n5 v1 Tname=N5
            w1 v2 dD
            r1 v35 dD
            r2 v2 Ttype=site,name=R2b Mn2@
            """
        When running osm2pgsql flex with parameters
            | --slim | --append |
        Then table test contains exactly
            | otype | oid | version |
            | N     | 4   | 1       |
            | N     | 4   | 2       |
            | N     | 5   | 1       |
            | W     | 2   | 10      |
            | W     | 2   | NULL    |
            | R     | 2   | 1       |
            | R     | 2   | 2       |


    Scenario: Automatic delete can be disabled completely
        Given the lua style
            """
            local table = osm2pgsql.define_table{
                name = 'test',
                auto_delete = '',
                ids = { type = 'any', type_column = 'otype', id_column = 'oid'},
                columns = {{ column = 'version', type = 'int'}}
            }

            local other = osm2pgsql.define_table{
                name = 'other',
                ids = { type = 'any', type_column = 'otype', id_column = 'oid'},
                columns = {}
            }

            local function process(object)
                table:insert{version = object.version}
                other:insert{}
            end

            osm2pgsql.process_node = process
            osm2pgsql.process_way = process
            osm2pgsql.process_relation = process
            """
        When running osm2pgsql flex with parameters
            | --slim |
        Given the grid
            | 1 |   |   |
            |   | 5 | 4 |
            |   |   |   |
        And the OSM data
            """
            n1 v3 dD
            n4 v2 Tname=N4
            n5 v1 Tname=N5
            w1 v2 dD
            r1 v35 dD
            r2 v2 Ttype=site,name=R2b Mn2@
            """
        When running osm2pgsql flex with parameters
            | --slim | --append |
        Then table test contains exactly
            | otype | oid | version |
            | N     | 1   | 2       |
            | N     | 4   | 1       |
            | N     | 4   | 2       |
            | N     | 5   | 1       |
            | W     | 1   | 1       |
            | W     | 2   | 10      |
            | W     | 2   | NULL    |
            | R     | 1   | 34      |
            | R     | 2   | 1       |
            | R     | 2   | 2       |
        And table other has 4 rows
