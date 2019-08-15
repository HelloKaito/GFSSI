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
from lib.lib_constant import FULL_VALUE
from lib.lib_proj import ProjCore, meter2degree


def _write_out_file(out_file, result):
    out_dir = os.path.dirname(out_file)
    if not os.path.isdir(out_dir):
        os.makedirs(out_dir)

    valid_count = 0
    for key in result:
        if result[key] is None:
            continue
        else:
            valid_count += 1
    if valid_count == 0:
        print('没有足够的有效数据，不生成结果文件')
        return

    try:
        compression = 'gzip'
        compression_opts = 5
        shuffle = True
        with h5py.File(out_file, 'w') as hdf5:
            for dataset in result.keys():
                if 'Lat' in dataset or 'Lon' in dataset:
                    dtype = np.float32
                else:
                    dtype = np.int32
                data = result[dataset]
                data[np.isnan(data)] = FULL_VALUE
                hdf5.create_dataset(dataset,
                                    dtype=dtype, data=result[dataset], compression=compression,
                                    compression_opts=compression_opts,
                                    shuffle=shuffle)
        print('>>> 成功生成HDF文件{}'.format(out_file))
    except Exception as why:
        print(why)
        print('HDF写入数据错误')
        os.remove(out_file)


def make_disk_projlut(res='4km', out_file=None):
    if res == '4km':
        res_int = 4000
        lats = FY4ASSI.get_latitude()
        lons = FY4ASSI.get_longitude()
    else:
        raise ValueError('不支持此分辨率: {}'.format(res))
    res_degree = meter2degree(res_int)
    projstr = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    proj = ProjCore(projstr, res_degree, unit="deg", pt_tl=(23, 81), pt_br=(179.5, -81))  # 角点也要放在格点中心位置
    result = proj.create_lut(lats=lats, lons=lons)
    proj.grid_lonslats()
    result['Longitude'] = proj.lons
    result['Latitude'] = proj.lats
    result['row_col'] = np.array([proj.row, proj.col], dtype=np.int32)
    print(result['row_col'])
    _write_out_file(out_file, result)
