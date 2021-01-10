import sys
import json
import jinja2
import tempfile
import mako.template
from mako import exceptions 

if __name__ == '__main__': 
    f = open(sys.argv[1])
    desc = json.load(f)
    docstring = "automatically generated"
    # C++ stub to interface between verilator and python
    template = mako.template.Template(
    r"""
    #include <pybind11/pybind11.h>
    #include <pybind11/stl.h>
    #include <backends/cxxrtl/cxxrtl_vcd.h>
    #include "top.cpp"
    #include <iostream>
    #include <fstream> 
    
    namespace py = pybind11;
    cxxrtl_design::p_${name} *top;
    cxxrtl::debug_items dbg;
    cxxrtl::vcd_writer vcd;
    using namespace std;
    std::ofstream waves("waves.vcd");
    
    static cxxrtl_design::p_${name}* create(bool trace) {
        top = new cxxrtl_design::p_${name}();
        if (trace) { 
            top->debug_info(dbg);
            vcd.timescale(1, "us");
            vcd.add_without_memories(dbg);
        }
        return(top);
    }
    
    void sample(cxxrtl_design::p_${name}* self, int i) {
        vcd.sample(i);
        waves << vcd.buffer;
        vcd.buffer.clear();
    }
    % for output in outputs:
    ${output[1]} ${output[0]}(cxxrtl_design::p_${name}* self) {
            return top->p_${output[0]}.get<${output[1]}>();
    }
    % endfor
    
    % for input in inputs:
    void ${input[0]}(cxxrtl_design::p_${name}* self, ${input[1]} val) {
            top->p_${input[0]}.set<${input[1]}>(val);
    }
    % endfor
    
    PYBIND11_MODULE(tb, m) {
        m.doc() = "${docstring}";

        py::class_<cxxrtl_design::p_${name}>(m, "top")
            .def( py::init(&create))
            .def("step", &top->step)
        % for input in inputs:
            .def_property("${input[0]}",nullptr, &${input[0]})
        % endfor
        % for output in outputs:
            .def_property("${output[0]}", &${output[0]}, nullptr)
        % endfor
            .def("sample", &sample)
        ;
    }""")

    try:
        template.render(
            docstring = docstring,
            name = desc['name'],
            inputs = desc['inputs'],
            outputs = desc['outputs']
        )
    except:
        print(exceptions.html_error_template().render())
    
    
    # Render the template and write it to a temp file
    with open(sys.argv[2],"w") as fd:
        fd.write(template.render(
            docstring = docstring,
            name = desc['name'],
            inputs = desc['inputs'],
            outputs = desc['outputs']
        ))
        fd.flush() 