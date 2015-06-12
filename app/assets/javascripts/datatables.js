$(document).on('page:change', function(){

  $('table.datatable').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[1, 'asc']],
    "columnDefs": [
      { orderable: false, targets: [0] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });

  $('table.datatable-admin').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[1, 'asc']],
    "columnDefs": [
      { orderable: false, targets: [0, -1] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });


  $('table.datatable-prison').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[2, 'desc']],
    "columnDefs": [
      { orderable: false, targets: [0] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });

  $('table.datatable-prison-admin').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[2, 'desc']],
    "columnDefs": [
      { orderable: false, targets: [0, -1] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });


  $('table.datatable-article').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[3, 'desc']],
    "columnDefs": [
      { orderable: false, targets: [0] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });

  $('table.datatable-article-admin').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[3, 'desc']],
    "columnDefs": [
      { orderable: false, targets: [0, -1] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });



  $('table.datatable-tag').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[2, 'desc']],
    "columnDefs": [
      { orderable: false, targets: [0] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });

  $('table.datatable-tag-admin').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[2, 'desc']],
    "columnDefs": [
      { orderable: false, targets: [0, -1] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });




  $('table.datatable-article').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[3, 'desc']],
    "columnDefs": [
      { orderable: false, targets: [0] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });

  $('table.datatable-article-admin').dataTable({
    "destroy": true,
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "processing": true,
    "order": [[3, 'desc']],
    "columnDefs": [
      { orderable: false, targets: [0, -1] }
    ],
    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    responsive: true
  });

});
