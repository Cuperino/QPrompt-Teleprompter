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
