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

#include "systemfontchooserdialog.h"
#include "ui_systemfontchooserdialog.h"
#include <QDebug>
#include <QTextFormat>

SystemFontChooserDialog::SystemFontChooserDialog(QWidget *parent)
    : QDialog(parent)
    , ui(new Ui::SystemFontChooserDialog)
{
    ui->setupUi(this);
}

SystemFontChooserDialog::~SystemFontChooserDialog()
{
    delete ui;
}

QString SystemFontChooserDialog::fontFamily() const
{
    return m_fontFamily;
}

void SystemFontChooserDialog::setFontFamily(QString fontFamily)
{
    const QFont font(fontFamily, previewPointSize);
    ui->fontSelector->setCurrentFont(font);
}

void SystemFontChooserDialog::show(const QString &fontFamily, const QString &text)
{
    setFontFamily(fontFamily);
    ui->textPreviewLabel->setText(text);
    ui->textPreviewLabel->setText(text);
    QDialog::show();
}

void SystemFontChooserDialog::on_fontSelector_currentFontChanged(const QFont &f)
{
    const QFont font(f.family(), previewPointSize);
    ui->textPreviewLabel->setFont(font);
}

void SystemFontChooserDialog::on_SystemFontChooserDialog_accepted()
{
    m_fontFamily = ui->fontSelector->currentFont().family();
    emit fontFamilyChanged(m_fontFamily);
}
