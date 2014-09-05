#ifndef ID_TRACKER_HPP
#define ID_TRACKER_HPP

#include "osmtypes.hpp"
#include <string>
#include <boost/noncopyable.hpp>
#include <boost/scoped_ptr.hpp>

struct id_tracker : public boost::noncopyable {
    id_tracker();
    ~id_tracker();

    void mark(osmid_t id);
    bool is_marked(osmid_t id);
    osmid_t pop_mark();
    size_t size();

private:
    struct pimpl;
    boost::scoped_ptr<pimpl> impl;
};

#endif /* ID_TRACKER_HPP */
