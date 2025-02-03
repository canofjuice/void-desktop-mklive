#!/bin/bash

rm -r include_cinnamon/etc/skel/.config
rm -r include_xfce/etc/skel/.config
mv include_cinnamon/etc/skel/config include_cinnamon/etc/skel/.config
mv include_xfce/etc/skel/config include_xfce/etc/skel/.config