# Copyright (c) 2012-2013 ARM Limited
# All rights reserved.
#
# The license below extends only to copyright in the software and shall
# not be construed as granting a license to any other intellectual
# property including but not limited to intellectual property relating
# to a hardware implementation of the functionality of the software
# licensed hereunder.  You may use the software subject to the license
# terms below provided that you ensure that this notice is replicated
# unmodified and in its entirety in all distributions of the software,
# modified or unmodified, in source code or in binary form.
#
# Copyright (c) 2006-2008 The Regents of The University of Michigan
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Authors: Steve Reinhardt

# Simple test script
#
# "m5 test.py"

import optparse
import sys
import os

import m5
from m5.defines import buildEnv
from m5.objects import *
from m5.util import addToPath, fatal, warn

addToPath('../')

from ruby import Ruby

from common import Options
from common import Simulation
from common import CacheConfig
from common import CpuConfig
from common import MemConfig
from common.Caches import *
from common.cpu2000 import *
from common import Scheme

import spec17_benchmarks

# Check if KVM support has been enabled, we might need to do VM
# configuration if that's the case.
have_kvm_support = 'BaseKvmCPU' in globals()
def is_kvm_cpu(cpu_class):
    return have_kvm_support and cpu_class != None and \
        issubclass(cpu_class, BaseKvmCPU)

def get_processes(options):
    """Interprets provided options and returns a list of processes"""

    multiprocesses = []
    inputs = []
    outputs = []
    errouts = []
    pargs = []

    workloads = options.cmd.split(';')
    if options.input != "":
        inputs = options.input.split(';')
    if options.output != "":
        outputs = options.output.split(';')
    if options.errout != "":
        errouts = options.errout.split(';')
    if options.options != "":
        pargs = options.options.split(';')

    idx = 0
    for wrkld in workloads:
        process = Process(pid = 100 + idx)
        process.executable = wrkld
        process.cwd = os.getcwd()

        if options.env:
            with open(options.env, 'r') as f:
                process.env = [line.rstrip() for line in f]

        if len(pargs) > idx:
            process.cmd = [wrkld] + pargs[idx].split()
        else:
            process.cmd = [wrkld]

        if len(inputs) > idx:
            process.input = inputs[idx]
        if len(outputs) > idx:
            process.output = outputs[idx]
        if len(errouts) > idx:
            process.errout = errouts[idx]

        multiprocesses.append(process)
        idx += 1

    if options.smt:
        assert(options.cpu_type == "DerivO3CPU")
        return multiprocesses, idx
    else:
        return multiprocesses, 1


parser = optparse.OptionParser()
Options.addCommonOptions(parser)
Options.addSEOptions(parser)
Scheme.add_CC_Options(parser)

parser.add_option("-b", "--benchmark", type="string", default="", help="The SPEC benchmark to be loaded.")
parser.add_option("--benchmark_stdout", type="string", default="", help="Absolute path for stdout redirection for the benchmark.")
parser.add_option("--benchmark_stderr", type="string", default="", help="Absolute path for stderr redirection for the benchmark.")


if '--ruby' in sys.argv:
    Ruby.define_options(parser)

(options, args) = parser.parse_args()

if args:
    print "Error: script doesn't take any positional arguments"
    sys.exit(1)

#multiprocesses = []
numThreads = 1

# [CleanupCache] Based on scheme, set sim options.
Scheme.set_scheme_options(options)
    
# Select Benchmark
if options.benchmark:
    print 'Selected SPEC_CPU2017 benchmark'
    if options.benchmark == 'perlbench':
        print '--> perlbench'
        process = spec17_benchmarks.perlbench
    elif options.benchmark == 'gcc':
        print '--> gcc'
        process = spec17_benchmarks.gcc
    elif options.benchmark == 'bwaves':
        print '--> bwaves'
        process = spec17_benchmarks.bwaves
    elif options.benchmark == 'mcf':
        print '--> mcf'
        process = spec17_benchmarks.mcf
    elif options.benchmark == 'cactuBSSN':
        print '--> cactuBSSN'
        process = spec17_benchmarks.cactuBSSN
    elif options.benchmark == 'namd':
        print '--> namd'
        process = spec17_benchmarks.namd
    elif options.benchmark == 'parest':
        print '--> parest'
        process = spec17_benchmarks.parest
    elif options.benchmark == 'povray':
        print '--> povray'
        process = spec17_benchmarks.povray
    elif options.benchmark == 'lbm':
        print '--> lbm'
        process = spec17_benchmarks.lbm
    elif options.benchmark == 'omnetpp':
        print '--> omnetpp'
        process = spec17_benchmarks.omnetpp
    elif options.benchmark == 'wrf':
        print '--> wrf'
        process = spec17_benchmarks.wrf
    elif options.benchmark == 'xalancbmk':
        print '--> xalancbmk'
        process = spec17_benchmarks.xalancbmk
    elif options.benchmark == 'x264':
        print '--> x264'
        process = spec17_benchmarks.x264
    elif options.benchmark == 'blender':
        print '--> blender'
        process = spec17_benchmarks.blender
    elif options.benchmark == 'cam4':
        print '--> cam4'
        process = spec17_benchmarks.cam4
    elif options.benchmark == 'deepsjeng':
        print '--> deepsjeng'
        process = spec17_benchmarks.deepsjeng
    elif options.benchmark == 'imagick':
        print '--> imagick'
        process = spec17_benchmarks.imagick
    elif options.benchmark == 'leela':
        print '--> leela'
        process = spec17_benchmarks.leela
    elif options.benchmark == 'nab':
        print '--> nab'
        process = spec17_benchmarks.nab
    elif options.benchmark == 'fotonik3d':
        print '--> fotonik3d'
        process = spec17_benchmarks.fotonik3d
    elif options.benchmark == 'roms':
        print '--> roms'
        process = spec17_benchmarks.roms
    elif options.benchmark == 'xz':
        print '--> xz'
        process = spec17_benchmarks.xz
    # if options.benchmark == 'perlbench':
    #     print '--> perlbench'
    #     process = spec17_benchmarks.perlbench
    # elif options.benchmark == 'bzip2':
    #     print '--> bzip2'
    #     process = spec17_benchmarks.bzip2
    # elif options.benchmark == 'gcc':
    #     print '--> gcc'
    #     process = spec17_benchmarks.gcc
    # elif options.benchmark == 'bwaves':
    #     print '--> bwaves'
    #     process = spec17_benchmarks.bwaves
    # elif options.benchmark == 'gamess':
    #     print '--> gamess'
    #     process = spec17_benchmarks.gamess
    # elif options.benchmark == 'mcf':
    #     print '--> mcf'
    #     process = spec17_benchmarks.mcf
    # elif options.benchmark == 'milc':
    #     print '--> milc'
    #     process = spec17_benchmarks.milc
    # elif options.benchmark == 'zeusmp':
    #     print '--> zeusmp'
    #     process = spec17_benchmarks.zeusmp
    # elif options.benchmark == 'gromacs':
    #     print '--> gromacs'
    #     process = spec17_benchmarks.gromacs
    # elif options.benchmark == 'cactusADM':
    #     print '--> cactusADM'
    #     process = spec17_benchmarks.cactusADM
    # elif options.benchmark == 'leslie3d':
    #     print '--> leslie3d'
    #     process = spec17_benchmarks.leslie3d
    # elif options.benchmark == 'namd':
    #     print '--> namd'
    #     process = spec17_benchmarks.namd
    # elif options.benchmark == 'gobmk':
    #     print '--> gobmk'
    #     process = spec17_benchmarks.gobmk
    # elif options.benchmark == 'dealII':
    #     print '--> dealII'
    #     process = spec17_benchmarks.dealII
    # elif options.benchmark == 'soplex':
    #     print '--> soplex'
    #     process = spec17_benchmarks.soplex
    # elif options.benchmark == 'povray':
    #     print '--> povray'
    #     process = spec17_benchmarks.povray
    # elif options.benchmark == 'calculix':
    #     print '--> calculix'
    #     process = spec17_benchmarks.calculix
    # elif options.benchmark == 'hmmer':
    #     print '--> hmmer'
    #     process = spec17_benchmarks.hmmer
    # elif options.benchmark == 'sjeng':
    #     print '--> sjeng'
    #     process = spec17_benchmarks.sjeng
    # elif options.benchmark == 'GemsFDTD':
    #     print '--> GemsFDTD'
    #     process = spec17_benchmarks.GemsFDTD
    # elif options.benchmark == 'libquantum':
    #     print '--> libquantum'
    #     process = spec17_benchmarks.libquantum
    # elif options.benchmark == 'h264ref':
    #     print '--> h264ref'
    #     process = spec17_benchmarks.h264ref
    # elif options.benchmark == 'tonto':
    #     print '--> tonto'
    #     process = spec17_benchmarks.tonto
    # elif options.benchmark == 'lbm':
    #     print '--> lbm'
    #     process = spec17_benchmarks.lbm
    # elif options.benchmark == 'omnetpp':
    #     print '--> omnetpp'
    #     process = spec17_benchmarks.omnetpp
    # elif options.benchmark == 'astar':
    #     print '--> astar'
    #     process = spec17_benchmarks.astar
    # elif options.benchmark == 'wrf':
    #     print '--> wrf'
    #     process = spec17_benchmarks.wrf
    # elif options.benchmark == 'sphinx3':
    #     print '--> sphinx3'
    #     process = spec17_benchmarks.sphinx3
    # elif options.benchmark == 'xalancbmk':
    #     print '--> xalancbmk'
    #     process = spec17_benchmarks.xalancbmk
    # elif options.benchmark == 'specrand_i':
    #     print '--> specrand_i'
    #     process = spec17_benchmarks.specrand_i
    # elif options.benchmark == 'specrand_f':
    #     print '--> specrand_f'
    #     process = spec17_benchmarks.specrand_f
    else:
        print "No recognized SPEC2017 benchmark selected! Exiting."
        sys.exit(1)
else:
    print >> sys.stderr, "Need --benchmark switch to specify SPEC CPU2017 workload. Exiting!\n"
    sys.exit(1)

# Set process stdout/stderr
if options.benchmark_stdout:
    process.output = options.benchmark_stdout
    print "Process stdout file: " + process.output
if options.benchmark_stderr:
    process.errout = options.benchmark_stderr
    print "Process stderr file: " + process.errout

#if options.bench:
#    apps = options.bench.split("-")
#    if len(apps) != options.num_cpus:
#        print "number of benchmarks not equal to set num_cpus!"
#        sys.exit(1)
#
#    for app in apps:
#        try:
#            if buildEnv['TARGET_ISA'] == 'alpha':
#                exec("workload = %s('alpha', 'tru64', '%s')" % (
#                        app, options.spec_input))
#            elif buildEnv['TARGET_ISA'] == 'arm':
#                exec("workload = %s('arm_%s', 'linux', '%s')" % (
#                        app, options.arm_iset, options.spec_input))
#            else:
#                exec("workload = %s(buildEnv['TARGET_ISA', 'linux', '%s')" % (
#                        app, options.spec_input))
#            multiprocesses.append(workload.makeProcess())
#        except:
#            print >>sys.stderr, "Unable to find workload for %s: %s" % (
#                    buildEnv['TARGET_ISA'], app)
#            sys.exit(1)
#elif options.cmd:
#    multiprocesses, numThreads = get_processes(options)
#else:
#    print >> sys.stderr, "No workload specified. Exiting!\n"
#    sys.exit(1)


(CPUClass, test_mem_mode, FutureClass) = Simulation.setCPUClass(options)
CPUClass.numThreads = numThreads

# Check -- do not allow SMT with multiple CPUs
if options.smt and options.num_cpus > 1:
    fatal("You cannot use SMT with multiple CPUs!")

np = options.num_cpus
system = System(cpu = [CPUClass(cpu_id=i) for i in xrange(np)],
                mem_mode = test_mem_mode,
                mem_ranges = [AddrRange(options.mem_size)],
                cache_line_size = options.cacheline_size)
if numThreads > 1:
    system.multi_thread = True

# Create a top-level voltage domain
system.voltage_domain = VoltageDomain(voltage = options.sys_voltage)

# Create a source clock for the system and set the clock period
system.clk_domain = SrcClockDomain(clock =  options.sys_clock,
                                   voltage_domain = system.voltage_domain)

# Create a CPU voltage domain
system.cpu_voltage_domain = VoltageDomain()

# Create a separate clock domain for the CPUs
system.cpu_clk_domain = SrcClockDomain(clock = options.cpu_clock,
                                       voltage_domain =
                                       system.cpu_voltage_domain)

# If elastic tracing is enabled, then configure the cpu and attach the elastic
# trace probe
if options.elastic_trace_en:
    CpuConfig.config_etrace(CPUClass, system.cpu, options)

# All cpus belong to a common cpu_clk_domain, therefore running at a common
# frequency.
for cpu in system.cpu:
    cpu.clk_domain = system.cpu_clk_domain

if is_kvm_cpu(CPUClass) or is_kvm_cpu(FutureClass):
    if buildEnv['TARGET_ISA'] == 'x86':
        system.kvm_vm = KvmVM()
        for process in multiprocesses:
            process.useArchPT = True
            process.kvmInSE = True
    else:
        fatal("KvmCPU can only be used in SE mode with x86")

# Sanity check
if options.fastmem:
    if CPUClass != AtomicSimpleCPU:
        fatal("Fastmem can only be used with atomic CPU!")
    if (options.caches or options.l2cache):
        fatal("You cannot use fastmem in combination with caches!")

if options.simpoint_profile:
    if not options.fastmem:
        # Atomic CPU checked with fastmem option already
        fatal("SimPoint generation should be done with atomic cpu and fastmem")
    if np > 1:
        fatal("SimPoint generation not supported with more than one CPUs")

for i in xrange(np):
    system.cpu[i].workload = process
    print process.cmd

    #if options.smt:
    #    system.cpu[i].workload = multiprocesses
    #elif len(multiprocesses) == 1:
    #    system.cpu[i].workload = multiprocesses[0]
    #else:
    #    system.cpu[i].workload = multiprocesses[i]

    if options.fastmem:
        system.cpu[i].fastmem = True

    if options.simpoint_profile:
        system.cpu[i].addSimPointProbe(options.simpoint_interval)

    if options.checker:
        system.cpu[i].addCheckerCpu()

    system.cpu[i].createThreads()


if options.ruby:
    Ruby.create_system(options, False, system)
    assert(options.num_cpus == len(system.ruby._cpu_ports))

    system.ruby.clk_domain = SrcClockDomain(clock = options.ruby_clock,
                                        voltage_domain = system.voltage_domain)
    for i in xrange(np):
        ruby_port = system.ruby._cpu_ports[i]

        # Create the interrupt controller and connect its ports to Ruby
        # Note that the interrupt controller is always present but only
        # in x86 does it have message ports that need to be connected
        system.cpu[i].createInterruptController()

        # Connect the cpu's cache ports to Ruby
        system.cpu[i].icache_port = ruby_port.slave
        system.cpu[i].dcache_port = ruby_port.slave
        if buildEnv['TARGET_ISA'] == 'x86':
            system.cpu[i].interrupts[0].pio = ruby_port.master
            system.cpu[i].interrupts[0].int_master = ruby_port.slave
            system.cpu[i].interrupts[0].int_slave = ruby_port.master
            system.cpu[i].itb.walker.port = ruby_port.slave
            system.cpu[i].dtb.walker.port = ruby_port.slave
else:
    MemClass = Simulation.setMemClass(options)
    system.membus = SystemXBar()
    system.system_port = system.membus.slave
    CacheConfig.config_cache(options, system)
    MemConfig.config_mem(options, system)

#  Configure simulation scheme
if CPUClass == DerivO3CPU:
    Scheme.scheme_config_cpu(CPUClass, system.cpu, options)

root = Root(full_system = False, system = system)
Simulation.run(options, root, system, FutureClass)
