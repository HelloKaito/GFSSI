#!/usr/bin/env python 
# -*- coding: utf-8 -*-
# @Time    : 2019/9/19 12:01
# @Author  : AnNing

# 参考
# https://matplotlib.org/3.1.1/tutorials/colors/colorbar_only.html

import matplotlib.pyplot as plt
import matplotlib as mpl
from lib.lib_constant import *

aid_path = get_aid_path()

kwargs = {
    'Orbit': COLORBAR_RANGE_ORBIT,
    'Daily': COLORBAR_RANGE_DAILY,
    'Monthly': COLORBAR_RANGE_MONTHLY,
    'Yearly': COLORBAR_RANGE_YEARLY,
}

# for k, r in kwargs.items():
#     fig, ax = plt.subplots(figsize=(1, 8))
#     fig.subplots_adjust(right=0.5)
#     cmap = plt.get_cmap('jet')
#     vmin, vmax = r
#     orientation = 'vertical'
#     # orientation = 'horizontal'
#     norm = plt.Normalize(vmin=vmin, vmax=vmax)
#     cb1 = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
#                                     norm=norm,
#                                     orientation=orientation)
#     # cb1.set_label('Kwh/m^2')
#     plt.tight_layout()
#     alpha = 0
#     fig.patch.set_alpha(alpha)
#     fig.savefig(os.path.join(aid_path, 'colormap_{}.png'.format(k)))


for k, r in kwargs.items():
    fig, ax = plt.subplots(figsize=(8, 1))
    fig.subplots_adjust(bottom=0.5)
    cmap = plt.get_cmap('jet')
    vmin, vmax = r
    # orientation = 'vertical'
    orientation = 'horizontal'
    norm = plt.Normalize(vmin=vmin, vmax=vmax)
    cb1 = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
                                    norm=norm,
                                    orientation=orientation)
    # cb1.set_label('Kwh/m^2')
    plt.tight_layout()
    alpha = 0
    fig.patch.set_alpha(alpha)
    fig.savefig(os.path.join(aid_path, 'colormap_{}.png'.format(k)))