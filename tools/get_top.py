#!/usr/bin/env python3

# Copyright 2022 Google LLC2
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# author: Sarah Clark <sarahclark@google.com>

"""
Parses the @FPGA_TOP directive in a Verilog file and writes to standard output
"""
import sys
import re

top_comment = re.compile(r'(?i)\s*//\s*@FPGA_TOP\s+(\w+)')


def main():
    top_module = 'fpga_top'
    if len(sys.argv) == 2:
        fname = sys.argv[1];
        with open(fname) as source_file:
            for line in source_file:
                match_result = top_comment.match(line)
                if match_result is not None:
                    top_module = match_result.group(1)
                    break
    print(top_module)

if __name__ == '__main__':
    main()
