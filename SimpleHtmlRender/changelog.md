## 1.0.3
* 支持修改htmlContent内容时重新解析

已知问题：
当属性值中有`&`符号时(比如a标签的href属性)，解析会报 `Error: unterminated entity ref`这个错误，但不影响解析

## 1.0.2
* 新增支持 img标签，但不支持alt属性；高度为文字高度，宽度自适应

展示img标签需要申请网络权限

## 1.0.1

* 完善 example
* 完善 oh-package.json5

无功能修改

## 1.0.0

* 支持的标签：span、font、br、a。
* 支持的属性：color、font-color、size、font-size、background、href。