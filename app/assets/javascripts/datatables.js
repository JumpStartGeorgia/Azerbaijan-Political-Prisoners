$(document).ready(function(){

  $('table.datatable').dataTable({
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[1, 'asc']],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]]
  });

  $('table.datatable-admin').dataTable({
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[1, 'asc']],
    "columnDefs": [
      { orderable: false, targets: [-1] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]]
  });

});