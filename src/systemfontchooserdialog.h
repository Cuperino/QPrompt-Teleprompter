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

#ifndef SYSTEMFONTCHOOSERDIALOG_H
#define SYSTEMFONTCHOOSERDIALOG_H

#include <QDialog>

namespace Ui
{
class SystemFontChooserDialog;
}

class SystemFontChooserDialog : public QDialog
{
    Q_OBJECT
public:
    explicit SystemFontChooserDialog(QWidget *parent = nullptr);
    ~SystemFontChooserDialog();

    Q_INVOKABLE void show(const QString &fontFamily, const QString &text);
    QString fontFamily() const;

signals:
    void fontFamilyChanged(const QString &);

private slots:
    void on_fontSelector_currentFontChanged(const QFont &f);

    void on_SystemFontChooserDialog_accepted();

private:
    const int previewPointSize = 72;
    Ui::SystemFontChooserDialog *ui;
    QString m_fontFamily;
    void setFontFamily(QString);
};

#endif // SYSTEMFONTCHOOSERDIALOG_H
