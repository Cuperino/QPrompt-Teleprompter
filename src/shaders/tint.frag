/****************************************************************************
**
** QPrompt
** Copyright (C) 2023 Javier O. Cordero Pérez
**
** This file is part of QPrompt.
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, version 3 of the License.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
**
****************************************************************************/

// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    vec4 tint;
} ubuf;

void main()
{
    vec4 c = texture(source, qt_TexCoord0);
    float lo = min(min(c.x, c.y), c.z) - 0.5;
    float hi = max(max(c.x, c.y), c.z);
    fragColor = vec4(mix(vec3(lo), vec3(hi), ubuf.tint.xyz), c.w);
}
