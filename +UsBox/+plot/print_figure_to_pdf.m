function print_figure_to_pdf(h,file_name,paper_size)



set(h,'Units','Inches');


set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',paper_size)
print(h,file_name,'-dpdf','-r0')