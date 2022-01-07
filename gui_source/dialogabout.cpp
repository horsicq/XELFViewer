/* Copyright (c) 2019-2022 hors<horsicq@gmail.com>
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
#include "dialogabout.h"
#include "ui_dialogabout.h"

DialogAbout::DialogAbout(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::DialogAbout)
{
    ui->setupUi(this);

    ui->labelVersion->setText(QString("<span style=\" font-weight:600;\">%1</span>")
                              .arg(XOptions::getTitle(X_APPLICATIONDISPLAYNAME,X_APPLICATIONVERSION)));

    ui->labelBugreports->setText(QString("<html><head/><body><p><span style=\" font-weight:600;\">%1</span>: <a href=\"mailto:horsicq@gmail.com\"><span style=\" text-decoration: underline; color:#ff0000;\">horsicq@gmail.com</span></a></p></body></html>")
                                .arg(tr("Bugreports")));
    ui->labelWebsite->setText(QString("<html><head/><body><p><span style=\" font-weight:600;\">%1</span>: <a href=\"http://ntinfo.biz\"><span style=\" text-decoration: underline; color:#ff0000;\">http://ntinfo.biz</span></a></p></body></html>")
                                .arg(tr("Website")));
    ui->labelDonate->setText(QString("<html><head/><body><p><span style=\" font-weight:600;\">%1(Paypal): </span><a href=\"mailto:ntinfo.re@gmail.com\"><span style=\" text-decoration: underline; color:#ff0000;\">ntinfo.re@gmail.com</span></a></p></body></html>")
                                .arg(tr("Donate")));
    ui->labelSourceCode->setText(QString("<html><head/><body><p><span style=\" font-weight:600;\">%1: </span><a href=\"https://github.com/horsicq/XELFViewer\"><span style=\" text-decoration: underline; color:#ff0000;\">https://github.com/horsicq/XELFViewer</span></a></p></body></html>")
                                .arg(tr("Source code")));
    ui->labelThanks->setText(QString("<html><head/><body>"
                                         "<p align=\"center\"><span style=\" font-weight:600;\">%1:</span></p>"
                                         "<p align=\"center\">"
                                             "<a href=\"https://www.mentebinaria.com.br/\"><span style=\" text-decoration: underline; color:#ff0000; \">Fernando Mercês</span></a>, "
                                             "<a href=\"http://sandsprite.com/\"><span style=\" text-decoration: underline; color:#ff0000;\">David Zimmer</span></a>, "
                                             "<a href=\"https://github.com/miso-xyz\"><span style=\" text-decoration: underline; color:#ff0000;\">misonothx</span></a>, "
                                         "</p>"
                                         "<p align=\"center\">"
                                            "<a href=\"https://twitter.com/frenchyeti\"><span style=\" text-decoration: underline; color:#ff0000;\">FrenchYeti</span></a>, "
                                            "<a href=\"https://github.com/fr0zenbag\"><span style=\" text-decoration: underline; color:#ff0000;\">fr0zenbag</span></a>, "
                                            "<a href=\"https://github.com/AandersonL\"><span style=\" text-decoration: underline; color:#ff0000;\">Anderson Leite</span></a>, "
                                         "</p>"
                                         "<p align=\"center\">"
                                            "<a href=\"https://github.com/filipnavara\"><span style=\" text-decoration: underline; color:#ff0000;\">Filip Navara</span></a>, "
                                            "<a href=\"https://www.ashemery.com/\"><span style=\" text-decoration: underline; color:#ff0000;\">Ali Hadi</span></a>, "
                                            "<a href=\"http://mrexodia.re/\"><span style=\" text-decoration: underline; color:#ff0000;\">Duncan Ogilvie</span></a>, "
                                         "</p>"
                                         "<p align=\"center\">"
                                            "<a href=\"https://github.com/leandrofroes\"><span style=\" text-decoration: underline; color:#ff0000;\">Leandro Fróes</span></a>"
                                         "</p>"
                                     "</body></html>")
                                .arg(tr("Thanks")));

}

DialogAbout::~DialogAbout()
{
    delete ui;
}

void DialogAbout::on_pushButtonOK_clicked()
{
    this->close();
}
