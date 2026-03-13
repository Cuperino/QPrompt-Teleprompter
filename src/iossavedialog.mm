/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Pérez
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

#include "iossavedialog.h"

#include <QFile>
#include <QMetaObject>

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface QPromptDocPickerDelegate : NSObject <UIDocumentPickerDelegate>
@property (nonatomic, assign) IosSaveDialog *dialog;
@end

@implementation QPromptDocPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    if (urls.count > 0) {
        NSURL *url = urls.firstObject;
        QUrl fileUrl = QUrl::fromNSURL(url);
        QMetaObject::invokeMethod(_dialog, [=]() {
            Q_EMIT _dialog->accepted(fileUrl);
        }, Qt::QueuedConnection);
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    QMetaObject::invokeMethod(_dialog, [=]() {
        Q_EMIT _dialog->rejected();
    }, Qt::QueuedConnection);
}

@end

IosSaveDialog *IosSaveDialog::s_instance = nullptr;

IosSaveDialog::IosSaveDialog(QObject *parent)
    : QObject(parent)
{
    s_instance = this;
}

IosSaveDialog *IosSaveDialog::instance()
{
    return s_instance;
}

IosSaveDialog *IosSaveDialog::create(QQmlEngine *engine, QJSEngine *)
{
    if (!s_instance)
        s_instance = new IosSaveDialog(engine);
    return s_instance;
}

void IosSaveDialog::saveDocument(const QString &htmlContent, const QString &suggestedName)
{
    if (!m_tempDir.isValid())
        return;

    QString fileName = suggestedName;
    if (fileName.isEmpty())
        fileName = QStringLiteral("document.html");

    QString tempFilePath = m_tempDir.path() + QStringLiteral("/") + fileName;
    QFile tempFile(tempFilePath);
    if (!tempFile.open(QFile::WriteOnly | QFile::Truncate)) {
        Q_EMIT rejected();
        return;
    }
    tempFile.write(htmlContent.toUtf8());
    tempFile.close();

    NSURL *fileURL = [NSURL fileURLWithPath:tempFilePath.toNSString()];

    QPromptDocPickerDelegate *delegate = [[QPromptDocPickerDelegate alloc] init];
    delegate.dialog = this;

    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initForExportingURLs:@[fileURL] asCopy:YES];
    picker.delegate = delegate;
    picker.shouldShowFileExtensions = YES;

    // Keep delegate alive for the duration of the picker
    static const char kDelegateKey = 0;
    objc_setAssociatedObject(picker, &kDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootVC.presentedViewController)
        rootVC = rootVC.presentedViewController;
    [rootVC presentViewController:picker animated:YES completion:nil];
}
