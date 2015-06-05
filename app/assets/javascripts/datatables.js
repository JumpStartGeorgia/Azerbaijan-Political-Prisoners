$(document).on('page:change', function(){

  $('table.datatable').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[1, 'asc']],
    "columnDefs": [
      { orderable: false, targets: [0] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]]
  });

  $('table.datatable-admin').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[1, 'asc']],
    "columnDefs": [
      { orderable: false, targets: [0, -1] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]]
  });

});
