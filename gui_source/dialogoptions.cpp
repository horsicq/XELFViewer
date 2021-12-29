/* Copyright (c) 2019-2021 hors<horsicq@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#include "dialogoptions.h"
#include "ui_dialogoptions.h"

DialogOptions::DialogOptions(QWidget *parent, XOptions *pOptions) :
    QDialog(parent),
    ui(new Ui::DialogOptions)
{
    ui->setupUi(this);

    this->g_pOptions=pOptions;

    g_pStaticScanOptionsWidget=new StaticScanOptionsWidget(this);
    g_pSearchSignaturesOptionsWidget=new SearchSignaturesOptionsWidget(this);
    g_pXHexViewOptionsWidget=new XHexViewOptionsWidget(this);

    ui->widgetOptions->setOptions(pOptions,X_APPLICATIONDISPLAYNAME);

    ui->widgetOptions->addPage(g_pStaticScanOptionsWidget,tr("Scan"));
    g_pStaticScanOptionsWidget->setOptions(pOptions);

    ui->widgetOptions->addPage(g_pSearchSignaturesOptionsWidget,tr("Signatures"));
    g_pSearchSignaturesOptionsWidget->setOptions(pOptions);

    ui->widgetOptions->addPage(g_pXHexViewOptionsWidget,tr("Hex"));
    g_pXHexViewOptionsWidget->setOptions(pOptions);

    ui->widgetOptions->setCurrentPage(1);
}

DialogOptions::~DialogOptions()
{
    delete ui;
}

void DialogOptions::on_pushButtonOK_clicked()
{
    ui->widgetOptions->save();
    g_pStaticScanOptionsWidget->save();
    g_pSearchSignaturesOptionsWidget->save();
    g_pXHexViewOptionsWidget->save();

    if(g_pOptions->isRestartNeeded())
    {
        QMessageBox::information(this,tr("Information"),tr("Please restart the application"));
    }

    this->close();
}

void DialogOptions::on_pushButtonCancel_clicked()
{
    this->close();
}
