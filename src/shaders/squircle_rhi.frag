// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#version 440

layout(location = 0) in vec2 coords;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    float t;
    float y_dir;
};

void main()
{
    float i = 1.0 - (pow(abs(coords.x), 4.0) + pow(abs(coords.y), 4.0));
    i = smoothstep(t - 0.8, t + 0.8, i);
    i = floor(i * 20.0) / 20.0;
    fragColor = vec4(coords * 0.5 + 0.5, i, i);
}
