#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
@Time    : 2019/8/8
@Author  : AnNing
"""
import os
import h5py
import numpy as np
from lib.lib_read_ssi import FY4ASSI
from lib.lib_proj import ProjCore, meter2degree


def _write_out_file(out_file, result):
    out_dir = os.path.dirname(out_file)
    if not os.path.isdir(out_dir):
        os.makedirs(out_dir)

    try:
        compression = 'gzip'
        compression_opts = 5
        shuffle = True
        with h5py.File(out_file, 'w') as hdf5:
            for dataset in result.keys():
                print(dataset)
                data = result[dataset]
                data[np.isnan(data)] = -999
                hdf5.create_dataset(dataset,
                                    dtype=np.int32, data=result[dataset], compression=compression,
                                    compression_opts=compression_opts,
                                    shuffle=shuffle)
        print('>>> 成功生成HDF文件{}'.format(out_file))
    except Exception as why:
        print(why)
        print('HDF写入数据错误')
        os.remove(out_file)


lats = FY4ASSI.get_latitude()
lons = FY4ASSI.get_longitude()

projstr = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

for res, res_int in [('1km', 1000), ('4km', 4000)]:

    res_degree = meter2degree(res_int)
    proj = ProjCore(projstr, res_degree, unit="deg", pt_tl=(-179.5, 89.5), pt_br=(179.5, -89.5))  # 角点也要放在格点中心位置
    result = proj.create_lut(lats=lats, lons=lons)
    print(proj.row, proj.col)
    result['row_col'] = np.array([proj.row, proj.col], dtype=np.int32)
    print(type(result['row_col']))
    print(result['row_col'])

    out_file = 'Aid/lonlat_projlut_{}_{}row_{}col.hdf'.format(res_int, proj.row, proj.col)
    _write_out_file(out_file, result)


# # 使用
# proj_row = proj.row
# proj_col = proj.col
# data = None
# proj_data = np.array((row, col), dtype=data.dtype)
# proj_data[proj_i, proj_j] = data[pre_i, pre_j]
