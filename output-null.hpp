/* Implements dummy output-layer processing for testing.
*/

#ifndef OUTPUT_NULL_H
#define OUTPUT_NULL_H

#include "output.hpp"

class output_null_t : public output_t {
public:
    output_null_t(const middle_query_t* mid_, const options_t &options);
    output_null_t(const output_null_t& other);
    virtual ~output_null_t();

    virtual std::shared_ptr<output_t> clone(const middle_query_t* cloned_middle) const;

    int start();
    void stop();
    void commit();
    void cleanup(void);

    void enqueue_ways(pending_queue_t &job_queue, osmid_t id, size_t output_id, size_t& added);
    int pending_way(osmid_t id, int exists);

    void enqueue_relations(pending_queue_t &job_queue, osmid_t id, size_t output_id, size_t& added);
    int pending_relation(osmid_t id, int exists);

    int node_add(osmium::Node const &node, double lat, double lon, bool extra_tags) override;
    int way_add(osmium::Way const &way, bool extra_tags) override;
    int relation_add(osmium::Relation const &rel, bool extra_tags) override;

    int node_modify(osmium::Node const &node, double lat, double lon, bool extra_tags) override;
    int way_modify(osmium::Way const &way, bool extra_tags) override;
    int relation_modify(osmium::Relation const &rel, bool extra_tags) override;

    int node_delete(osmid_t id);
    int way_delete(osmid_t id);
    int relation_delete(osmid_t id);
};

#endif
