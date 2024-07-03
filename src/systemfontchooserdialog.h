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

    // Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)

    // QML_ELEMENT
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
