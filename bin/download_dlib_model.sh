#!/bin/bash

wget http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2
bzip2 -dk shape_predictor_68_face_landmarks.dat.bz2
mv shape_predictor_68_face_landmarks.dat models/dlibshape_predictor_68_face_landmarks.dat
rum -rf shape_predictor_68_face_landmarks.dat.bz2