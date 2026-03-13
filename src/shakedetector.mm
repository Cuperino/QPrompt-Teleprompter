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

#include "shakedetector.h"

#ifdef Q_OS_IOS
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <QMetaObject>

static IMP s_originalMotionEnded = nullptr;

static void qprompt_motionEnded(id self, SEL _cmd, UIEventSubtype motion, UIEvent *event)
{
    if (motion == UIEventSubtypeMotionShake) {
        if (ShakeDetector *detector = ShakeDetector::instance()) {
            QMetaObject::invokeMethod(detector, "shakeDetected", Qt::QueuedConnection);
            return;
        }
    }
    if (s_originalMotionEnded) {
        reinterpret_cast<void(*)(id, SEL, UIEventSubtype, UIEvent *)>(s_originalMotionEnded)(self, _cmd, motion, event);
    }
}
#endif

ShakeDetector *ShakeDetector::s_instance = nullptr;

ShakeDetector::ShakeDetector(QObject *parent)
    : QObject(parent)
{
    s_instance = this;
    setupShakeDetection();
}

ShakeDetector *ShakeDetector::instance()
{
    return s_instance;
}

ShakeDetector *ShakeDetector::create(QQmlEngine *engine, QJSEngine *)
{
    if (!s_instance)
        s_instance = new ShakeDetector(engine);
    return s_instance;
}

#ifdef Q_OS_IOS
void ShakeDetector::setupShakeDetection()
{
    SEL sel = @selector(motionEnded:withEvent:);
    Class windowClass = [UIWindow class];
    Method original = class_getInstanceMethod(windowClass, sel);
    const char *types = method_getTypeEncoding(original);

    if (class_addMethod(windowClass, sel, reinterpret_cast<IMP>(qprompt_motionEnded), types)) {
        s_originalMotionEnded = method_getImplementation(original);
    } else {
        s_originalMotionEnded = method_setImplementation(original, reinterpret_cast<IMP>(qprompt_motionEnded));
    }
}

void ShakeDetector::showUndoRedoDialog(bool canUndo, bool canRedo)
{
    if (!canUndo && !canRedo)
        return;

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Undo", nil)
        message:nil
        preferredStyle:UIAlertControllerStyleAlert];

    if (canUndo) {
        [alert addAction:[UIAlertAction
            actionWithTitle:NSLocalizedString(@"Undo", nil)
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                QMetaObject::invokeMethod(ShakeDetector::instance(), "undoRequested", Qt::QueuedConnection);
            }]];
    }

    if (canRedo) {
        [alert addAction:[UIAlertAction
            actionWithTitle:NSLocalizedString(@"Redo", nil)
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                QMetaObject::invokeMethod(ShakeDetector::instance(), "redoRequested", Qt::QueuedConnection);
            }]];
    }

    [alert addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Cancel", nil)
        style:UIAlertActionStyleCancel
        handler:nil]];

    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootVC.presentedViewController)
        rootVC = rootVC.presentedViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}
#else
void ShakeDetector::setupShakeDetection()
{
}

void ShakeDetector::showUndoRedoDialog(bool, bool)
{
}
#endif
